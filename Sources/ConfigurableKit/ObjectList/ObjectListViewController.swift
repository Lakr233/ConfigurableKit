//
//  ObjectListViewController.swift
//  ConfigurableKit
//
//  A full-featured list view controller with search, sort, CRUD,
//  drag-drop reordering, and multi-selection editing.
//
//  Encapsulates UITableViewDiffableDataSource, UISearchController,
//  and all related UIKit patterns behind a simple ObjectListDataSource interface.
//

import Combine
import UIKit

open class ObjectListViewController<DataSource: ObjectListDataSource>: UITableViewController,
    UISearchResultsUpdating,
    UISearchBarDelegate,
    UISearchControllerDelegate,
    UITableViewDragDelegate,
    UITableViewDropDelegate
{
    public typealias Item = DataSource.Item

    // MARK: - Properties

    public let dataSource: DataSource
    public weak var delegate: ObjectListViewControllerDelegate?

    private var diffableDataSource: UITableViewDiffableDataSource<Int, UUID>!
    private let searchController = UISearchController(searchResultsController: nil)
    private var searchDebounceWorkItem: DispatchWorkItem?
    private var currentSortCriterion: ObjectListSortCriterion<Item>?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    public init(dataSource: DataSource) {
        self.dataSource = dataSource
        if !dataSource.sortCriteria.isEmpty {
            currentSortCriterion = dataSource.sortCriteria.first
        }
        super.init(style: .plain)
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError()
    }

    // MARK: - Lifecycle

    override open func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = .zero
        tableView.allowsMultipleSelectionDuringEditing = true

        setupDiffableDataSource()
        setupSearch()
        setupNavigationBar()
        setupDragDrop()
        subscribeToChanges()
        applySnapshot(animated: false)
        delegate?.objectListViewControllerDidLoad(self)
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applySnapshot(animated: false)
    }

    // MARK: - Diffable Data Source

    private func setupDiffableDataSource() {
        diffableDataSource = UITableViewDiffableDataSource<Int, UUID>(
            tableView: tableView
        ) { [weak self] tableView, _, itemID in
            guard let self else { return UITableViewCell() }

            let cellID = "ObjectListCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID)
                ?? UITableViewCell(style: .default, reuseIdentifier: cellID)

            // Remove previous ConfigurableView
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
            cell.backgroundColor = .clear

            guard let item = dataSource.item(for: itemID) else { return cell }

            let configurableView = ConfigurableView()
            configurableView.isUserInteractionEnabled = false
            dataSource.configure(cell: configurableView, for: item)

            let wrapper = AutoLayoutMarginView(configurableView)
            cell.contentView.addSubview(wrapper)
            wrapper.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                wrapper.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                wrapper.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                wrapper.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                wrapper.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
            ])

            let editingBg = UIView()
            editingBg.backgroundColor = .systemGray5
            cell.multipleSelectionBackgroundView = editingBg

            return cell
        }

        diffableDataSource.defaultRowAnimation = .fade
    }

    // MARK: - Snapshot

    private func applySnapshot(animated: Bool = true) {
        let items = filteredAndSortedItems()
        var snapshot = NSDiffableDataSourceSnapshot<Int, UUID>()
        snapshot.appendSections([0])
        let ids = items.map(\.id)
        snapshot.appendItems(ids, toSection: 0)
        snapshot.reconfigureItems(ids)
        diffableDataSource.apply(snapshot, animatingDifferences: animated)
    }

    private func filteredAndSortedItems() -> [Item] {
        let query = searchController.searchBar.text ?? ""
        var result: [Item] = if query.isEmpty {
            dataSource.items
        } else {
            dataSource.items.filter { $0.matches(query: query) }
        }

        if let criterion = currentSortCriterion {
            result.sort(by: criterion.compare)
        }

        return result
    }

    // MARK: - Search

    private func setupSearch() {
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.autocorrectionType = .no
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        if #available(iOS 16.0, *) {
            navigationItem.preferredSearchBarPlacement = .stacked
        }
    }

    open func updateSearchResults(for _: UISearchController) {
        searchDebounceWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.applySnapshot()
        }
        searchDebounceWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: workItem)
    }

    // MARK: - Navigation Bar

    private func setupNavigationBar() {
        var rightItems = [UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), menu: buildActionsMenu())]
        delegate?.objectListViewController(self, configureTrailingBarButtonItems: &rightItems)
        navigationItem.rightBarButtonItems = rightItems

        var leftItems: [UIBarButtonItem] = []
        delegate?.objectListViewController(self, configureLeadingBarButtonItems: &leftItems)
        if !leftItems.isEmpty {
            navigationItem.leftBarButtonItems = leftItems
        }
    }

    // MARK: - Actions Menu

    private func buildActionsMenu() -> UIMenu {
        var children: [UIMenuElement] = []

        // Add
        let add = UIAction(
            title: String(localized: "Add"),
            image: UIImage(systemName: "plus")
        ) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                guard let _ = await self.dataSource.createItem(from: self) else { return }
                self.applySnapshot()
            }
        }
        children.append(add)

        // Edit mode
        let editTitle = tableView.isEditing
            ? String(localized: "Done")
            : String(localized: "Select")
        let edit = UIAction(
            title: editTitle,
            image: UIImage(systemName: tableView.isEditing ? "checkmark.circle" : "checkmark.circle")
        ) { [weak self] _ in
            guard let self else { return }
            setEditing(!tableView.isEditing, animated: true)
        }
        children.append(edit)

        // Sort submenu
        if !dataSource.sortCriteria.isEmpty {
            children.append(buildSortMenu())
        }

        return UIMenu(children: children)
    }

    private func buildSortMenu() -> UIMenu {
        let actions = dataSource.sortCriteria.map { criterion in
            UIAction(
                title: String(localized: criterion.title),
                image: UIImage(systemName: criterion.icon),
                state: currentSortCriterion?.id == criterion.id ? .on : .off
            ) { [weak self] _ in
                self?.currentSortCriterion = criterion
                self?.applySnapshot()
                self?.rebuildActionsMenu()
            }
        }
        return UIMenu(
            title: String(localized: "Sort By"),
            image: UIImage(systemName: "arrow.up.arrow.down"),
            children: actions
        )
    }

    private func rebuildActionsMenu() {
        navigationItem.rightBarButtonItems?.first?.menu = buildActionsMenu()
    }

    // MARK: - Edit Mode

    override open func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
        updateEditingUI()
    }

    private func updateEditingUI() {
        if tableView.isEditing {
            let selectedCount = tableView.indexPathsForSelectedRows?.count ?? 0
            let deleteButton = UIBarButtonItem(
                title: selectedCount > 0
                    ? String(localized: "Delete (\(selectedCount))")
                    : String(localized: "Delete"),
                style: .plain,
                target: self,
                action: #selector(deleteSelected)
            )
            deleteButton.tintColor = .systemRed
            deleteButton.isEnabled = selectedCount > 0

            var editingToolbarItems: [UIBarButtonItem] = [
                UIBarButtonItem(systemItem: .flexibleSpace),
                deleteButton,
                UIBarButtonItem(systemItem: .flexibleSpace),
            ]
            delegate?.objectListViewController(self, configureToolbarItems: &editingToolbarItems)
            toolbarItems = editingToolbarItems
            navigationController?.setToolbarHidden(false, animated: true)
        } else {
            navigationController?.setToolbarHidden(true, animated: true)
            toolbarItems = nil
        }
    }

    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            updateEditingUI()
            return
        }

        tableView.deselectRow(at: indexPath, animated: true)

        guard let itemID = diffableDataSource.itemIdentifier(for: indexPath),
              let item = dataSource.item(for: itemID) else { return }

        Task { @MainActor in
            guard let _ = await dataSource.editItem(item, from: self) else { return }
            applySnapshot()
        }
    }

    override open func tableView(_ tableView: UITableView, didDeselectRowAt _: IndexPath) {
        if tableView.isEditing {
            updateEditingUI()
        }
    }

    @objc private func deleteSelected() {
        guard let indexPaths = tableView.indexPathsForSelectedRows, !indexPaths.isEmpty else { return }

        let ids = Set(indexPaths.compactMap { diffableDataSource.itemIdentifier(for: $0) })
        guard !ids.isEmpty else { return }

        let alert = UIAlertController(
            title: String(localized: "Delete \(ids.count) Item(s)?"),
            message: String(localized: "This action cannot be undone."),
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(
            title: String(localized: "Delete"),
            style: .destructive
        ) { [weak self] _ in
            self?.dataSource.removeItems(ids)
            self?.applySnapshot()
            self?.setEditing(false, animated: true)
        })
        alert.addAction(UIAlertAction(title: String(localized: "Cancel"), style: .cancel))

        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = toolbarItems?.first(where: { $0.style == .plain })
        }

        present(alert, animated: true)
    }

    // MARK: - Multi-Selection Gesture

    override open func tableView(_: UITableView, shouldBeginMultipleSelectionInteractionAt _: IndexPath) -> Bool {
        true
    }

    override open func tableView(_: UITableView, didBeginMultipleSelectionInteractionAt _: IndexPath) {
        setEditing(true, animated: true)
    }

    // MARK: - Swipe to Delete

    override open func tableView(
        _: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        guard !tableView.isEditing else { return nil }
        guard let itemID = diffableDataSource.itemIdentifier(for: indexPath) else { return nil }

        let delete = UIContextualAction(style: .destructive, title: String(localized: "Delete")) {
            [weak self] _, _, completion in
            self?.dataSource.removeItems([itemID])
            self?.applySnapshot()
            completion(true)
        }
        delete.image = UIImage(systemName: "trash")

        return UISwipeActionsConfiguration(actions: [delete])
    }

    // MARK: - Context Menu

    override open func tableView(
        _: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point _: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let itemID = diffableDataSource.itemIdentifier(for: indexPath),
              let item = dataSource.item(for: itemID) else { return nil }

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self else { return nil }

            var actions: [UIMenuElement] = []

            let edit = UIAction(
                title: String(localized: "Edit"),
                image: UIImage(systemName: "pencil")
            ) { [weak self] _ in
                guard let self else { return }
                Task { @MainActor in
                    guard let _ = await self.dataSource.editItem(item, from: self) else { return }
                    self.applySnapshot()
                }
            }
            actions.append(edit)

            let delete = UIAction(
                title: String(localized: "Delete"),
                image: UIImage(systemName: "trash"),
                attributes: [.destructive]
            ) { [weak self] _ in
                self?.dataSource.removeItems([itemID])
                self?.applySnapshot()
            }
            actions.append(delete)

            let delegateActions = delegate?.objectListViewController(self, contextMenuActionsForItemWith: itemID) ?? []
            actions.append(contentsOf: delegateActions)

            return UIMenu(children: actions)
        }
    }

    // MARK: - Drag & Drop

    private func setupDragDrop() {
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
        tableView.dropDelegate = self
    }

    open func tableView(
        _: UITableView,
        itemsForBeginning _: UIDragSession,
        at indexPath: IndexPath
    ) -> [UIDragItem] {
        guard let itemID = diffableDataSource.itemIdentifier(for: indexPath) else { return [] }
        let provider = NSItemProvider(object: itemID.uuidString as NSString)
        let dragItem = UIDragItem(itemProvider: provider)
        dragItem.localObject = itemID
        return [dragItem]
    }

    open func tableView(
        _: UITableView,
        dropSessionDidUpdate session: UIDropSession,
        withDestinationIndexPath _: IndexPath?
    ) -> UITableViewDropProposal {
        guard session.localDragSession != nil else {
            return UITableViewDropProposal(operation: .cancel)
        }
        return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }

    open func tableView(
        _: UITableView,
        performDropWith coordinator: UITableViewDropCoordinator
    ) {
        let destinationIndexPath = coordinator.destinationIndexPath
            ?? IndexPath(row: dataSource.items.count, section: 0)

        for item in coordinator.items {
            guard let sourceID = item.dragItem.localObject as? UUID,
                  let sourceIndex = dataSource.items.firstIndex(where: { $0.id == sourceID })
            else { continue }

            dataSource.moveItem(from: sourceIndex, to: destinationIndexPath.row)
            applySnapshot(animated: false)
            coordinator.drop(item.dragItem, toRowAt: destinationIndexPath)
        }
    }

    // MARK: - Data Subscription

    private func subscribeToChanges() {
        dataSource.dataDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.applySnapshot()
            }
            .store(in: &cancellables)
    }
}
