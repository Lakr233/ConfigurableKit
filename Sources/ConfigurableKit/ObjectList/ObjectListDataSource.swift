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

    var sortCriteria: [ObjectListSortCriterion<Item>] {
        []
    }
}
