//
//  ObjectListDataSource.swift
//  ConfigurableKit
//
//  Data source protocol for ObjectListViewController.
//  Consumers implement this to provide data, CRUD actions, and cell rendering.
//

import Combine
import UIKit

@MainActor
public protocol ObjectListDataSource<Item>: AnyObject {
    associatedtype Item: ObjectListItem

    // MARK: - Data Access

    var items: [Item] { get }
    func item(for id: Item.ID) -> Item?

    // MARK: - CRUD

    func createItem(from viewController: UIViewController) async -> Item?
    func editItem(_ item: Item, from viewController: UIViewController) async -> Item?
    func removeItems(_ ids: Set<Item.ID>)
    func moveItem(from sourceIndex: Int, to destinationIndex: Int)
    func reorderItems(by orderedIDs: [Item.ID])

    // MARK: - Sort

    var sortCriteria: [ObjectListSortCriterion<Item>] { get }

    // MARK: - Cell Rendering

    func configure(cell: ConfigurableView, for item: Item)

    // MARK: - Change Notification

    var dataDidChange: AnyPublisher<Void, Never> { get }
}

// MARK: - Default Implementations

public extension ObjectListDataSource {
    func item(for id: Item.ID) -> Item? {
        items.first { $0.id == id }
    }

    func editItem(_: Item, from _: UIViewController) async -> Item? {
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

    var sortCriteria: [ObjectListSortCriterion<Item>] {
        []
    }
}
