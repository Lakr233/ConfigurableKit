//
//  ObjectListField.swift
//  ConfigurableKit
//
//  Describes a single field on an ObjectListItem for automatic
//  cell rendering and form generation.
//

import Foundation
import UIKit

// MARK: - Base Field

/// Describes one field of an `ObjectListFormItem`.
/// Subclass or use the built-in factory methods (`.text`, `.toggle`, `.picker`)
/// to create concrete field descriptors.
open class ObjectListField<Item: ObjectListItem> {
    public let id: String
    public let title: String.LocalizationValue
    public let icon: String
    public let isEditable: Bool

    public init(
        id: String,
        title: String.LocalizationValue,
        icon: String = "",
        isEditable: Bool = true
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.isEditable = isEditable
    }

    /// Read the field value as a display string.
    open func displayValue(from _: Item) -> String {
        ""
    }

    /// Create a `ConfigurableObject` for editing this field.
    /// The `keyPrefix` is a unique string scoped to this edit session.
    /// Pass the ephemeral `storage` so values don't pollute persistent storage.
    /// Return `nil` if the field is read-only.
    @MainActor
    open func createEditableObject(keyPrefix _: String, item _: Item, storage _: KeyValueStorage) -> ConfigurableObject? {
        nil
    }

    /// Read the edited value from storage and apply it back to the item.
    @MainActor
    open func applyValue(from _: KeyValueStorage, keyPrefix _: String, to _: inout Item) {}
}

// MARK: - Text Field

public final class ObjectListTextField<Item: ObjectListItem>: ObjectListField<Item> {
    public let keyPath: WritableKeyPath<Item, String>
    public let placeholder: String

    public init(
        id: String,
        title: String.LocalizationValue,
        icon: String = "textformat",
        isEditable: Bool = true,
        keyPath: WritableKeyPath<Item, String>,
        placeholder: String = ""
    ) {
        self.keyPath = keyPath
        self.placeholder = placeholder
        super.init(id: id, title: title, icon: icon, isEditable: isEditable)
    }

    override public func displayValue(from item: Item) -> String {
        item[keyPath: keyPath]
    }

    @MainActor
    override public func createEditableObject(keyPrefix: String, item: Item, storage: KeyValueStorage) -> ConfigurableObject? {
        guard isEditable else { return nil }
        let key = "\(keyPrefix).\(id)"
        return ConfigurableObject(
            icon: icon,
            title: title,
            key: key,
            defaultValue: item[keyPath: keyPath],
            annotation: TextInputAnnotation(placeholder: placeholder),
            storage: storage
        )
    }

    @MainActor
    override public func applyValue(from storage: KeyValueStorage, keyPrefix: String, to item: inout Item) {
        let key = "\(keyPrefix).\(id)"
        guard let data = storage.value(forKey: key),
              let decoded: String = CodableStorage.decode(data: data)?.decodingValue(defaultValue: "")
        else { return }
        item[keyPath: keyPath] = decoded
    }
}

// MARK: - Toggle Field

public final class ObjectListToggleField<Item: ObjectListItem>: ObjectListField<Item> {
    public let keyPath: WritableKeyPath<Item, Bool>

    public init(
        id: String,
        title: String.LocalizationValue,
        icon: String = "switch.2",
        isEditable: Bool = true,
        keyPath: WritableKeyPath<Item, Bool>
    ) {
        self.keyPath = keyPath
        super.init(id: id, title: title, icon: icon, isEditable: isEditable)
    }

    override public func displayValue(from item: Item) -> String {
        item[keyPath: keyPath] ? String(localized: "Yes") : String(localized: "No")
    }

    @MainActor
    override public func createEditableObject(keyPrefix: String, item: Item, storage: KeyValueStorage) -> ConfigurableObject? {
        guard isEditable else { return nil }
        let key = "\(keyPrefix).\(id)"
        return ConfigurableObject(
            icon: icon,
            title: title,
            key: key,
            defaultValue: item[keyPath: keyPath],
            annotation: .toggle,
            storage: storage
        )
    }

    @MainActor
    override public func applyValue(from storage: KeyValueStorage, keyPrefix: String, to item: inout Item) {
        let key = "\(keyPrefix).\(id)"
        guard let data = storage.value(forKey: key),
              let decoded: Bool = CodableStorage.decode(data: data)?.decodingValue(defaultValue: false)
        else { return }
        item[keyPath: keyPath] = decoded
    }
}

// MARK: - Picker Field

public final class ObjectListPickerField<Item: ObjectListItem, Value: Codable & Hashable>: ObjectListField<Item> {
    public let keyPath: WritableKeyPath<Item, Value>
    public let options: [(title: String.LocalizationValue, icon: String, value: Value)]

    public init(
        id: String,
        title: String.LocalizationValue,
        icon: String = "contextualmenu.and.cursorarrow",
        isEditable: Bool = true,
        keyPath: WritableKeyPath<Item, Value>,
        options: [(title: String.LocalizationValue, icon: String, value: Value)]
    ) {
        self.keyPath = keyPath
        self.options = options
        super.init(id: id, title: title, icon: icon, isEditable: isEditable)
    }

    override public func displayValue(from item: Item) -> String {
        let current = item[keyPath: keyPath]
        if let match = options.first(where: { ($0.value as AnyHashable) == (current as AnyHashable) }) {
            return String(localized: match.title)
        }
        return "\(current)"
    }

    @MainActor
    override public func createEditableObject(keyPrefix: String, item: Item, storage: KeyValueStorage) -> ConfigurableObject? {
        guard isEditable else { return nil }
        let key = "\(keyPrefix).\(id)"
        let menuOptions = options.map { opt in
            MenuAnnotation.Option(icon: opt.icon, title: opt.title, rawValue: opt.value)
        }
        return ConfigurableObject(
            icon: icon,
            title: title,
            key: key,
            defaultValue: item[keyPath: keyPath],
            annotation: .menu { menuOptions },
            storage: storage
        )
    }

    @MainActor
    override public func applyValue(from storage: KeyValueStorage, keyPrefix: String, to item: inout Item) {
        let key = "\(keyPrefix).\(id)"
        guard let data = storage.value(forKey: key),
              let decoded: Value = CodableStorage.decode(data: data)?.decodingValue(defaultValue: nil)
        else { return }
        item[keyPath: keyPath] = decoded
    }
}

// MARK: - Read-Only Display Field

public final class ObjectListDisplayField<Item: ObjectListItem, Value>: ObjectListField<Item> {
    public let keyPath: KeyPath<Item, Value>
    public let formatter: (Value) -> String

    public init(
        id: String,
        title: String.LocalizationValue,
        icon: String = "info.circle",
        keyPath: KeyPath<Item, Value>,
        formatter: @escaping (Value) -> String = { "\($0)" }
    ) {
        self.keyPath = keyPath
        self.formatter = formatter
        super.init(id: id, title: title, icon: icon, isEditable: false)
    }

    override public func displayValue(from item: Item) -> String {
        formatter(item[keyPath: keyPath])
    }
}

// MARK: - Convenience Factory Methods

public extension ObjectListField {
    static func text(
        id: String,
        title: String.LocalizationValue,
        icon: String = "textformat",
        isEditable: Bool = true,
        keyPath: WritableKeyPath<Item, String>,
        placeholder: String = ""
    ) -> ObjectListField<Item> {
        ObjectListTextField(
            id: id, title: title, icon: icon,
            isEditable: isEditable, keyPath: keyPath, placeholder: placeholder
        )
    }

    static func toggle(
        id: String,
        title: String.LocalizationValue,
        icon: String = "switch.2",
        isEditable: Bool = true,
        keyPath: WritableKeyPath<Item, Bool>
    ) -> ObjectListField<Item> {
        ObjectListToggleField(
            id: id, title: title, icon: icon,
            isEditable: isEditable, keyPath: keyPath
        )
    }

    static func picker<Value: Codable & Hashable>(
        id: String,
        title: String.LocalizationValue,
        icon: String = "contextualmenu.and.cursorarrow",
        isEditable: Bool = true,
        keyPath: WritableKeyPath<Item, Value>,
        options: [(title: String.LocalizationValue, icon: String, value: Value)]
    ) -> ObjectListField<Item> {
        ObjectListPickerField(
            id: id, title: title, icon: icon,
            isEditable: isEditable, keyPath: keyPath, options: options
        )
    }

    static func display<Value>(
        id: String,
        title: String.LocalizationValue,
        icon: String = "info.circle",
        keyPath: KeyPath<Item, Value>,
        formatter: @escaping (Value) -> String = { "\($0)" }
    ) -> ObjectListField<Item> {
        ObjectListDisplayField(
            id: id, title: title, icon: icon,
            keyPath: keyPath, formatter: formatter
        )
    }
}
