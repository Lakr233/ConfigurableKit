#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    import AppKit
    import Combine

    open class ObjectListViewController<DataSource: ObjectListDataSource>: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSMenuDelegate, ConfigurableSheetController.NavigationItemMenuProviding {
        public typealias Item = DataSource.Item

        private final class ObjectListCellView: NSTableCellView {
            let configurableView: ConfigurableView
            private let wrapper: AutoLayoutMarginView

            override var backgroundStyle: NSView.BackgroundStyle {
                didSet {
                    let isSelected = backgroundStyle == .emphasized
                    configurableView.alphaValue = isSelected ? 0.9 : 1
                }
            }

            override init(frame frameRect: NSRect) {
                let configurableView = ConfigurableView()
                configurableView.translatesAutoresizingMaskIntoConstraints = false
                self.configurableView = configurableView
                wrapper = AutoLayoutMarginView(
                    configurableView,
                    insets: CKEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
                )

                super.init(frame: frameRect)

                addSubview(wrapper)
                NSLayoutConstraint.activate([
                    wrapper.leadingAnchor.constraint(equalTo: leadingAnchor),
                    wrapper.trailingAnchor.constraint(equalTo: trailingAnchor),
                    wrapper.topAnchor.constraint(equalTo: topAnchor),
                    wrapper.bottomAnchor.constraint(equalTo: bottomAnchor),
                ])
            }

            func configure(with presentation: ObjectListRowPresentation) {
                configurableView.configure(icon: .image(optionalName: presentation.icon))
                configurableView.configure(title: presentation.title)
                configurableView.configure(description: presentation.detail)
            }

            @available(*, unavailable)
            required init?(coder _: NSCoder) {
                fatalError()
            }
        }

        public let dataSource: DataSource
        public weak var delegate: ObjectListViewControllerDelegate?

        private var cancellables = Set<AnyCancellable>()
        private var allItems: [Item] = []
        private var displayedItems: [Item] = []
        private var currentSortCriterion: ObjectListSortCriterion<Item>?
        private var isSelectionMode = false

        private let rootStack = NSStackView()

        private var isManualReorderAllowed: Bool {
            dataSource.shouldAllowManualReorder(
                query: searchField.stringValue,
                sortCriterion: currentSortCriterion
            )
        }

        private let controlsStack = NSStackView()
        private let searchField = NSSearchField()
        private let tableScrollView = NSScrollView()
        private let tableView = NSTableView()
        private let contextMenu = NSMenu()

        public init(dataSource: DataSource) {
            self.dataSource = dataSource
            super.init(nibName: nil, bundle: nil)
        }

        @available(*, unavailable)
        public required init?(coder _: NSCoder) {
            fatalError()
        }

        override open func loadView() {
            view = NSView()
            view.translatesAutoresizingMaskIntoConstraints = false
        }

        override open func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            subscribeToChanges()
            reloadRows()
            delegate?.objectListViewControllerDidLoad(self)
        }

        private func setupUI() {
            rootStack.orientation = .vertical
            rootStack.spacing = 8
            rootStack.translatesAutoresizingMaskIntoConstraints = false

            controlsStack.orientation = .horizontal
            controlsStack.spacing = 8
            controlsStack.alignment = .centerY
            controlsStack.translatesAutoresizingMaskIntoConstraints = false

            searchField.placeholderString = String(localized: "Search")
            searchField.target = self
            searchField.action = #selector(searchChanged)
            searchField.sendsSearchStringImmediately = true
            searchField.setContentHuggingPriority(.defaultLow, for: .horizontal)

            contextMenu.delegate = self
            tableView.menu = contextMenu

            tableScrollView.translatesAutoresizingMaskIntoConstraints = false
            tableScrollView.drawsBackground = false
            tableScrollView.hasVerticalScroller = true
            tableScrollView.autohidesScrollers = true
            tableScrollView.documentView = tableView
            tableView.autoresizingMask = [.width]

            tableView.translatesAutoresizingMaskIntoConstraints = false
            tableView.headerView = nil
            tableView.usesAlternatingRowBackgroundColors = false
            tableView.allowsColumnReordering = false
            tableView.allowsColumnResizing = false
            tableView.allowsMultipleSelection = false
            tableView.rowHeight = 48
            tableView.intercellSpacing = .zero
            tableView.dataSource = self
            tableView.delegate = self
            tableView.gridStyleMask = [.solidHorizontalGridLineMask]
            tableView.gridColor = .separatorColor
            tableView.target = self
            tableView.action = #selector(selectCurrentRow)
            tableView.allowsTypeSelect = false
            tableView.backgroundColor = .clear
            tableView.registerForDraggedTypes([.string])
            tableView.setDraggingSourceOperationMask(.move, forLocal: true)

            let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("main"))
            column.resizingMask = .autoresizingMask
            tableView.addTableColumn(column)

            controlsStack.addArrangedSubview(searchField)

            rootStack.addArrangedSubview(controlsStack)
            rootStack.addArrangedSubview(tableScrollView)
            view.addSubview(rootStack)

            NSLayoutConstraint.activate([
                rootStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                rootStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                rootStack.topAnchor.constraint(equalTo: view.topAnchor),
                rootStack.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                controlsStack.widthAnchor.constraint(equalTo: rootStack.widthAnchor),
                tableScrollView.widthAnchor.constraint(equalTo: rootStack.widthAnchor),
                searchField.widthAnchor.constraint(greaterThanOrEqualToConstant: 220),
            ])
        }

        @objc private func searchChanged() {
            applyFiltersAndSort()
        }

        public func navigationChromeLeadingItems(for _: ConfigurableSheetController) -> [NSMenuItem] {
            var items: [NSMenuItem] = []
            delegate?.objectListViewController(self, configureLeadingBarButtonItems: &items)
            return items
        }

        public func navigationChromeTrailingItems(for _: ConfigurableSheetController) -> [NSMenuItem] {
            var trailingItems = buildActionsMenuEntries()
            var delegateItems: [NSMenuItem] = []
            delegate?.objectListViewController(self, configureTrailingBarButtonItems: &delegateItems)
            if !delegateItems.isEmpty {
                trailingItems.append(.separator())
                trailingItems.append(contentsOf: delegateItems)
            }
            return trailingItems
        }

        private func buildActionsMenuEntries() -> [NSMenuItem] {
            var items: [NSMenuItem] = []

            let addItem = NSMenuItem(
                title: String(localized: "Add"),
                action: #selector(addItemFromActionsMenu),
                keyEquivalent: ""
            )
            addItem.target = self
            items.append(addItem)

            let selectTitle = isSelectionMode
                ? String(localized: "Done")
                : String(localized: "Select")
            let selectItem = NSMenuItem(
                title: selectTitle,
                action: #selector(toggleSelectionMode),
                keyEquivalent: ""
            )
            selectItem.target = self
            selectItem.state = isSelectionMode ? .on : .off
            items.append(selectItem)

            if isSelectionMode {
                let selectedCount = tableView.selectedRowIndexes.count
                let deleteTitle = selectedCount > 0
                    ? String(localized: "Delete (\(selectedCount))")
                    : String(localized: "Delete")
                let deleteItem = NSMenuItem(
                    title: deleteTitle,
                    action: #selector(deleteSelected),
                    keyEquivalent: ""
                )
                deleteItem.target = self
                deleteItem.isEnabled = selectedCount > 0
                items.append(deleteItem)
            }

            if !dataSource.sortCriteria.isEmpty {
                let sortRoot = NSMenuItem(title: String(localized: "Sort By"), action: nil, keyEquivalent: "")
                sortRoot.submenu = buildSortMenu()
                items.append(sortRoot)
            }

            return items
        }

        private func buildSortMenu() -> NSMenu {
            let menu = NSMenu()

            let manualItem = NSMenuItem(
                title: String(localized: "Manual Order"),
                action: #selector(selectSortCriterion(_:)),
                keyEquivalent: ""
            )
            manualItem.target = self
            manualItem.tag = 0
            manualItem.state = currentSortCriterion == nil ? .on : .off
            menu.addItem(manualItem)

            for (index, criterion) in dataSource.sortCriteria.enumerated() {
                let item = NSMenuItem(
                    title: String(localized: criterion.title),
                    action: #selector(selectSortCriterion(_:)),
                    keyEquivalent: ""
                )
                item.target = self
                item.tag = index + 1
                item.state = currentSortCriterion?.id == criterion.id ? .on : .off
                menu.addItem(item)
            }

            return menu
        }

        @objc private func addItemFromActionsMenu() {
            addItem()
        }

        @objc private func addItem() {
            Task { @MainActor in
                guard let _ = await dataSource.createItem(from: self) else { return }
                reloadRows()
            }
        }

        @objc private func toggleSelectionMode() {
            isSelectionMode.toggle()
            tableView.allowsMultipleSelection = isSelectionMode
            if !isSelectionMode {
                tableView.deselectAll(nil)
            }
            refreshNavigationChromeIfNeeded()
        }

        public func tableView(_: NSTableView, shouldSelectRow _: Int) -> Bool {
            true
        }

        @objc private func selectSortCriterion(_ sender: NSMenuItem) {
            let index = sender.tag
            if index <= 0 {
                currentSortCriterion = nil
            } else {
                currentSortCriterion = dataSource.sortCriteria[index - 1]
            }
            applyFiltersAndSort()
            refreshNavigationChromeIfNeeded()
        }

        @objc private func selectCurrentRow() {
            if tableView.clickedRow >= 0 {
                tableView.selectRowIndexes(IndexSet(integer: tableView.clickedRow), byExtendingSelection: false)
            }

            guard !tableView.selectedRowIndexes.isEmpty else { return }
            guard !tableView.selectedRowIndexes.contains(where: { $0 < 0 || $0 >= displayedItems.count }) else { return }
            guard !isSelectionMode else {
                refreshNavigationChromeIfNeeded()
                return
            }
            guard tableView.selectedRowIndexes.count == 1,
                  let selectedRow = tableView.selectedRowIndexes.first
            else { return }

            let item = displayedItems[selectedRow]

            Task { @MainActor in
                guard let _ = await dataSource.editItem(item, from: self) else { return }
                reloadRows()
            }
        }

        @objc private func deleteSelected() {
            let ids = selectedItemIDs(from: tableView.selectedRowIndexes)
            guard !ids.isEmpty else { return }
            confirmDelete(for: ids)
        }

        private func selectedItemIDs(from indexes: IndexSet) -> Set<Item.ID> {
            Set(indexes.compactMap { index -> Item.ID? in
                guard index >= 0, index < displayedItems.count else { return nil }
                return displayedItems[index].id
            })
        }

        private func confirmDelete(for ids: Set<Item.ID>) {
            let alert = NSAlert()
            alert.messageText = String(localized: "Delete \(ids.count) Item(s)?")
            alert.informativeText = String(localized: "This action cannot be undone.")
            alert.alertStyle = .warning
            alert.addButton(withTitle: String(localized: "Delete"))
            alert.addButton(withTitle: String(localized: "Cancel"))

            let handleResponse: (NSApplication.ModalResponse) -> Void = { [weak self] response in
                guard let self else { return }
                guard response == .alertFirstButtonReturn else { return }
                dataSource.removeItems(ids)
                reloadRows()
            }

            if let window = view.window {
                alert.beginSheetModal(for: window) { response in
                    handleResponse(response)
                }
            } else {
                handleResponse(alert.runModal())
            }
        }

        private func reloadRows() {
            allItems = dataSource.items
            applyFiltersAndSort()
        }

        private func applyFiltersAndSort() {
            displayedItems = dataSource.filteredAndSortedItems(
                from: allItems,
                query: searchField.stringValue,
                sortCriterion: currentSortCriterion
            )
            tableView.reloadData()
            refreshNavigationChromeIfNeeded()
        }

        private func subscribeToChanges() {
            dataSource.dataDidChange
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    self?.reloadRows()
                }
                .store(in: &cancellables)
        }

        private func refreshNavigationChromeIfNeeded() {
            if let sheet = parent as? ConfigurableSheetController {
                sheet.refreshNavigationChrome()
                return
            }
            if let sheet = parent?.parent as? ConfigurableSheetController {
                sheet.refreshNavigationChrome()
            }
        }

        public func numberOfRows(in _: NSTableView) -> Int {
            displayedItems.count
        }

        public func tableView(_: NSTableView, heightOfRow row: Int) -> CGFloat {
            guard row >= 0, row < displayedItems.count else { return 48 }
            return rowHeight(for: displayedItems[row])
        }

        public func tableViewSelectionDidChange(_: Notification) {
            refreshNavigationChromeIfNeeded()
        }

        public func menuNeedsUpdate(_ menu: NSMenu) {
            guard menu === contextMenu else { return }
            rebuildContextMenu()
        }

        private func rebuildContextMenu() {
            contextMenu.removeAllItems()

            let clickedRow = tableView.clickedRow
            guard clickedRow >= 0, clickedRow < displayedItems.count else { return }

            let item = displayedItems[clickedRow]
            let itemID = item.id

            if tableView.selectedRowIndexes.contains(clickedRow) {
                if tableView.selectedRowIndexes.count > 1 {
                    let deleteSelectedItem = NSMenuItem(
                        title: String(localized: "Delete"),
                        action: #selector(deleteSelected),
                        keyEquivalent: ""
                    )
                    deleteSelectedItem.target = self
                    contextMenu.addItem(deleteSelectedItem)
                    return
                }
            } else {
                tableView.selectRowIndexes(IndexSet(integer: clickedRow), byExtendingSelection: false)
                refreshNavigationChromeIfNeeded()
            }

            let editItem = NSMenuItem(
                title: String(localized: "Edit"),
                action: #selector(editFromContextMenu(_:)),
                keyEquivalent: ""
            )
            editItem.target = self
            editItem.representedObject = itemID
            contextMenu.addItem(editItem)

            let deleteItem = NSMenuItem(
                title: String(localized: "Delete"),
                action: #selector(deleteFromContextMenu(_:)),
                keyEquivalent: ""
            )
            deleteItem.target = self
            deleteItem.representedObject = itemID
            contextMenu.addItem(deleteItem)

            let delegateActions = delegate?.objectListViewController(self, contextMenuActionsForItemWith: itemID) ?? []
            if !delegateActions.isEmpty {
                contextMenu.addItem(.separator())
                for action in delegateActions {
                    contextMenu.addItem(action)
                }
            }
        }

        @objc private func editFromContextMenu(_ sender: NSMenuItem) {
            guard let itemID = sender.representedObject as? Item.ID,
                  let item = dataSource.item(for: itemID)
            else { return }

            Task { @MainActor in
                guard let _ = await dataSource.editItem(item, from: self) else { return }
                reloadRows()
            }
        }

        @objc private func deleteFromContextMenu(_ sender: NSMenuItem) {
            guard let itemID = sender.representedObject as? Item.ID else { return }
            confirmDelete(for: [itemID])
        }

        public func tableView(
            _: NSTableView,
            viewFor _: NSTableColumn?,
            row: Int
        ) -> NSView? {
            guard row >= 0, row < displayedItems.count else { return nil }

            let identifier = NSUserInterfaceItemIdentifier("object-list-cell")
            let cell: ObjectListCellView = if let reused = tableView.makeView(withIdentifier: identifier, owner: self) as? ObjectListCellView {
                reused
            } else {
                makeCellView(identifier: identifier)
            }

            let presentation = dataSource.rowPresentation(for: displayedItems[row])
            cell.configure(with: presentation)

            return cell
        }

        public func tableView(
            _: NSTableView,
            pasteboardWriterForRow row: Int
        ) -> NSPasteboardWriting? {
            guard isManualReorderAllowed,
                  row >= 0,
                  row < displayedItems.count
            else { return nil }

            let item = NSPasteboardItem()
            item.setString(displayedItems[row].id.uuidString, forType: .string)
            return item
        }

        public func tableView(
            _: NSTableView,
            validateDrop _: NSDraggingInfo,
            proposedRow _: Int,
            proposedDropOperation operation: NSTableView.DropOperation
        ) -> NSDragOperation {
            guard isManualReorderAllowed,
                  operation == .above
            else { return [] }
            return .move
        }

        public func tableView(
            _: NSTableView,
            acceptDrop info: NSDraggingInfo,
            row: Int,
            dropOperation _: NSTableView.DropOperation
        ) -> Bool {
            guard isManualReorderAllowed,
                  let sourceString = info.draggingPasteboard.string(forType: .string),
                  let sourceID = UUID(uuidString: sourceString)
            else { return false }

            var orderedIDs = displayedItems.map(\.id)
            guard let sourceIndex = orderedIDs.firstIndex(of: sourceID) else { return false }

            let destination = max(0, min(row, orderedIDs.count))
            var adjustedDestination = destination
            if sourceIndex < destination {
                adjustedDestination -= 1
            }
            guard sourceIndex != adjustedDestination else { return false }

            let movedID = orderedIDs.remove(at: sourceIndex)
            orderedIDs.insert(movedID, at: adjustedDestination)

            dataSource.reorderItems(by: orderedIDs)
            reloadRows()
            tableView.selectRowIndexes(IndexSet(integer: adjustedDestination), byExtendingSelection: false)
            return true
        }

        private func makeCellView(identifier: NSUserInterfaceItemIdentifier) -> ObjectListCellView {
            let cell = ObjectListCellView()
            cell.identifier = identifier
            return cell
        }

        private func rowHeight(for item: Item) -> CGFloat {
            let presentation = dataSource.rowPresentation(for: item)
            return presentation.detail.isEmpty ? 48 : 60
        }
    }
#endif
