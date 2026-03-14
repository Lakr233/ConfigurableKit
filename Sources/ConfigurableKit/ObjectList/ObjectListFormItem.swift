//
//  ObjectListFormItem.swift
//  ConfigurableKit
//
//  Protocol for items that declare their fields, enabling automatic
//  cell rendering and form generation.
//

import Foundation

/// An `ObjectListItem` that describes its own fields.
/// Conforming types get automatic cell rendering and create/edit forms.
public protocol ObjectListFormItem: ObjectListItem, Sendable {
    /// The fields that describe this item's properties.
    /// Order determines display order in both cells and edit forms.
    static var formFields: [ObjectListField<Self>] { get }

    /// Create a default instance for the "new item" flow.
    static func createDefault() -> Self
}
