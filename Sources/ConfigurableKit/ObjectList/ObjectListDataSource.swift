//
//  ObjectListDataSource.swift
//  ConfigurableKit
//
//  Data source protocol for ObjectListViewController.
//  Consumers implement this to provide data, CRUD actions, and cell rendering.
//

import Combine

public struct ObjectListRowPresentation: Sendable {
    public let icon: String
    public let title: String
    public let detail: String

    public init(icon: String = "", title: String, detail: String = "") {
        self.icon = icon
        self.title = title
        self.detail = detail
    }
}

@MainActor
public protocol ObjectListDataSource<Item>: AnyObject {
    associatedtype Item: ObjectListItem

    // MARK: - Data Access

    var items: [Item] { get }
    func item(for id: Item.ID) -> Item?

    // MARK: - CRUD

    func createItem(from viewController: CKViewController) async -> Item?
    func editItem(_ item: Item, from viewController: CKViewController) async -> Item?
    func removeItems(_ ids: Set<Item.ID>)
    func moveItem(from sourceIndex: Int, to destinationIndex: Int)
    func reorderItems(by orderedIDs: [Item.ID])

    // MARK: - Sort

    var sortCriteria: [ObjectListSortCriterion<Item>] { get }

    // MARK: - Row Presentation

    func rowPresentation(for item: Item) -> ObjectListRowPresentation

    // MARK: - Change Notification

    var dataDidChange: AnyPublisher<Void, Never> { get }
}

// MARK: - Default Implementations

public extension ObjectListDataSource {
    func item(for id: Item.ID) -> Item? {
        items.first { $0.id == id }
    }

    func editItem(_: Item, from _: CKViewController) async -> Item? {
        nil
    }

    func moveItem(from _: Int, to _: Int) {}

    func reorderItems(by orderedIDs: [Item.ID]) {
        var currentIDs = items.map(\.id)

        for (destinationIndex, itemID) in orderedIDs.enumerated() {
            guard let sourceIndex = currentIDs.firstIndex(of: itemID),
                  sourceIndex != destinationIndex
            else { continue }

            moveItem(from: sourceIndex, to: destinationIndex)

            let movedID = currentIDs.remove(at: sourceIndex)
            let safeDestinationIndex = min(destinationIndex, currentIDs.count)
            currentIDs.insert(movedID, at: safeDestinationIndex)
        }
    }

    func normalizedSearchQuery(_ query: String) -> String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func filteredAndSortedItems(
        from sourceItems: [Item],
        query: String,
        sortCriterion: ObjectListSortCriterion<Item>?
    ) -> [Item] {
        let normalizedQuery = normalizedSearchQuery(query)

        var result: [Item] = if normalizedQuery.isEmpty {
            sourceItems
        } else {
            sourceItems.filter { $0.matches(query: normalizedQuery) }
        }

        if let sortCriterion {
            result.sort(by: sortCriterion.compare)
        }

        return result
    }

    func filteredAndSortedItems(
        query: String,
        sortCriterion: ObjectListSortCriterion<Item>?
    ) -> [Item] {
        filteredAndSortedItems(from: items, query: query, sortCriterion: sortCriterion)
    }

    func shouldAllowManualReorder(
        query: String,
        sortCriterion: ObjectListSortCriterion<Item>?
    ) -> Bool {
        normalizedSearchQuery(query).isEmpty && sortCriterion == nil
    }

    var sortCriteria: [ObjectListSortCriterion<Item>] {
        []
    }

    func rowPresentation(for item: Item) -> ObjectListRowPresentation {
        .init(title: String(describing: item.id))
    }
}
