//
//  ConfigDSL+Elements.swift
//  ConfigurableKit
//
//  Created by GPT-5 Codex on 2025/11/10.
//

import Foundation

@MainActor
public struct Toggle: ConfigElementConvertible {
    private var element: ConfigToggleElement

    public init(
        storage: ConfigKey<Bool>,
        id: AnyHashable? = nil,
        isEnabled: Bool = true
    ) {
        let resolvedId: AnyHashable = id ?? AnyHashable(storage.rawValue)
        element = ConfigToggleElement(id: resolvedId, key: storage, isEnabled: isEnabled)
    }

    private init(element: ConfigToggleElement) {
        self.element = element
    }

    public func title(_ text: String) -> Toggle {
        var copy = element
        copy.title = text
        return Toggle(element: copy)
    }

    public func subtitle(_ text: String?) -> Toggle {
        var copy = element
        copy.subtitle = text
        return Toggle(element: copy)
    }

    public func icon(_ systemName: String?) -> Toggle {
        var copy = element
        copy.iconSystemName = systemName
        return Toggle(element: copy)
    }

    public func help(_ text: String?) -> Toggle {
        var copy = element
        copy.helpText = text
        return Toggle(element: copy)
    }

    public func onChange(_ handler: @escaping ConfigToggleHandler) -> Toggle {
        var copy = element
        copy.handler = handler
        return Toggle(element: copy)
    }

    public func disabled(_ isDisabled: Bool) -> Toggle {
        var copy = element
        copy.isEnabled = !isDisabled
        return Toggle(element: copy)
    }

    public func visible(_ isVisible: Bool) -> Toggle {
        var copy = element
        copy.isVisible = isVisible
        return Toggle(element: copy)
    }

    public func makeElementNode() -> ConfigElementNode {
        ConfigElementNode(id: element.id, kind: .toggle(element), isVisible: element.isVisible)
    }
}

@MainActor
public struct Action: ConfigElementConvertible {
    private var element: ConfigActionElement

    public init(
        _ title: String,
        id: AnyHashable? = nil,
        role: ConfigActionElement.Role = .normal,
        handler: ConfigActionHandler? = nil
    ) {
        let resolvedId: AnyHashable = id ?? AnyHashable(UUID())
        element = ConfigActionElement(
            id: resolvedId,
            title: title,
            role: role,
            handler: handler
        )
    }

    private init(element: ConfigActionElement) {
        self.element = element
    }

    public func subtitle(_ text: String?) -> Action {
        var copy = element
        copy.subtitle = text
        return Action(element: copy)
    }

    public func icon(_ systemName: String?) -> Action {
        var copy = element
        copy.iconSystemName = systemName
        return Action(element: copy)
    }

    public func role(_ role: ConfigActionElement.Role) -> Action {
        var copy = element
        copy.role = role
        return Action(element: copy)
    }

    public func disabled(_ isDisabled: Bool) -> Action {
        var copy = element
        copy.isEnabled = !isDisabled
        return Action(element: copy)
    }

    public func visible(_ isVisible: Bool) -> Action {
        var copy = element
        copy.isVisible = isVisible
        return Action(element: copy)
    }

    public func onTap(_ handler: @escaping ConfigActionHandler) -> Action {
        var copy = element
        copy.handler = handler
        return Action(element: copy)
    }

    public func makeElementNode() -> ConfigElementNode {
        ConfigElementNode(id: element.id, kind: .action(element), isVisible: element.isVisible)
    }
}

@MainActor
public struct InfoFooter: ConfigElementConvertible {
    private var element: ConfigInfoElement

    public init(_ text: String, id: AnyHashable? = nil, iconSystemName: String? = nil) {
        let resolvedId: AnyHashable = id ?? AnyHashable(UUID())
        element = ConfigInfoElement(id: resolvedId, text: text, iconSystemName: iconSystemName, style: .footer)
    }

    public func visible(_ isVisible: Bool) -> InfoFooter {
        let updated = ConfigInfoElement(
            id: element.id,
            text: element.text,
            iconSystemName: element.iconSystemName,
            style: element.style,
            isVisible: isVisible
        )
        return InfoFooter(updated)
    }

    private init(_ element: ConfigInfoElement) {
        self.element = element
    }

    public func makeElementNode() -> ConfigElementNode {
        ConfigElementNode(id: element.id, kind: .info(element), isVisible: element.isVisible)
    }
}

@MainActor
public struct InfoText: ConfigElementConvertible {
    private var element: ConfigInfoElement

    public init(_ text: String, id: AnyHashable? = nil, iconSystemName: String? = nil) {
        let resolvedId: AnyHashable = id ?? AnyHashable(UUID())
        element = ConfigInfoElement(id: resolvedId, text: text, iconSystemName: iconSystemName, style: .inline)
    }

    public func visible(_ isVisible: Bool) -> InfoText {
        let updated = ConfigInfoElement(
            id: element.id,
            text: element.text,
            iconSystemName: element.iconSystemName,
            style: element.style,
            isVisible: isVisible
        )
        return InfoText(updated)
    }

    private init(_ element: ConfigInfoElement) {
        self.element = element
    }

    public func makeElementNode() -> ConfigElementNode {
        ConfigElementNode(id: element.id, kind: .info(element), isVisible: element.isVisible)
    }
}

@MainActor
public struct Picker<Value: Codable & Equatable & Sendable>: ConfigElementConvertible {
    private var element: ConfigPickerElement<Value>

    public init(
        storage: ConfigKey<Value>,
        options: [ConfigPickerOption<Value>],
        id: AnyHashable? = nil
    ) {
        let resolvedId: AnyHashable = id ?? AnyHashable(storage.rawValue)
        element = ConfigPickerElement(id: resolvedId, key: storage, options: options)
    }

    private init(element: ConfigPickerElement<Value>) {
        self.element = element
    }

    public func title(_ text: String?) -> Picker {
        var copy = element
        copy.title = text
        return Picker(element: copy)
    }

    public func subtitle(_ text: String?) -> Picker {
        var copy = element
        copy.subtitle = text
        return Picker(element: copy)
    }

    public func icon(_ systemName: String?) -> Picker {
        var copy = element
        copy.iconSystemName = systemName
        return Picker(element: copy)
    }

    public func onChange(_ handler: @escaping ConfigPickerElement<Value>.Handler) -> Picker {
        var copy = element
        copy.handler = handler
        return Picker(element: copy)
    }

    public func visible(_ isVisible: Bool) -> Picker {
        var copy = element
        copy.isVisible = isVisible
        return Picker(element: copy)
    }

    public func makeElementNode() -> ConfigElementNode {
        let store = element.key.resolvedStore(default: ConfigurableKit.configStore)
        let erased = element.erase(using: store)
        return ConfigElementNode(id: erased.id, kind: .picker(erased), isVisible: erased.isVisible)
    }
}
