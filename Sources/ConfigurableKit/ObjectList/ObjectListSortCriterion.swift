//
//  ObjectListSortCriterion.swift
//  ConfigurableKit
//
//  Defines a sort criterion for ObjectListViewController.
//

import Foundation

open class ObjectListSortCriterion<Item: ObjectListItem> {
    public let id: String
    public let title: String.LocalizationValue
    public let icon: String
    public let compare: (Item, Item) -> Bool

    public init(
        id: String,
        title: String.LocalizationValue,
        icon: String = "arrow.up.arrow.down",
        compare: @escaping (Item, Item) -> Bool
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.compare = compare
    }
}
