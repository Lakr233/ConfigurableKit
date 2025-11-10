//
//  ConfigElements.swift
//  ConfigurableKit
//
//  Created by GPT-5 Codex on 2025/11/10.
//

import Combine
import Foundation

public typealias ConfigToggleHandler = @MainActor @Sendable (Bool) async -> Void
public typealias ConfigActionHandler = @MainActor @Sendable () async -> Void

public struct ConfigToggleElement {
    public var id: AnyHashable
    public let key: ConfigKey<Bool>
    public var title: String?
    public var subtitle: String?
    public var iconSystemName: String?
    public var helpText: String?
    public var isEnabled: Bool
    public var isVisible: Bool
    public var handler: ConfigToggleHandler?

    public init(
        id: AnyHashable,
        key: ConfigKey<Bool>,
        title: String? = nil,
        subtitle: String? = nil,
        iconSystemName: String? = nil,
        helpText: String? = nil,
        isEnabled: Bool = true,
        isVisible: Bool = true,
        handler: ConfigToggleHandler? = nil
    ) {
        self.id = id
        self.key = key
        self.title = title
        self.subtitle = subtitle
        self.iconSystemName = iconSystemName
        self.helpText = helpText
        self.isEnabled = isEnabled
        self.isVisible = isVisible
        self.handler = handler
    }
}

public struct ConfigActionElement {
    public enum Role {
        case normal
        case primary
        case destructive
    }

    public var id: AnyHashable
    public var title: String
    public var subtitle: String?
    public var iconSystemName: String?
    public var role: Role
    public var isEnabled: Bool
    public var isVisible: Bool
    public var handler: ConfigActionHandler?

    public init(
        id: AnyHashable,
        title: String,
        subtitle: String? = nil,
        iconSystemName: String? = nil,
        role: Role = .normal,
        isEnabled: Bool = true,
        isVisible: Bool = true,
        handler: ConfigActionHandler? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.iconSystemName = iconSystemName
        self.role = role
        self.isEnabled = isEnabled
        self.isVisible = isVisible
        self.handler = handler
    }
}

public struct ConfigInfoElement {
    public enum Style {
        case footer
        case inline
    }

    public var id: AnyHashable
    public var text: String
    public var iconSystemName: String?
    public var style: Style
    public var isVisible: Bool

    public init(
        id: AnyHashable,
        text: String,
        iconSystemName: String? = nil,
        style: Style = .footer,
        isVisible: Bool = true
    ) {
        self.id = id
        self.text = text
        self.iconSystemName = iconSystemName
        self.style = style
        self.isVisible = isVisible
    }
}

public struct ConfigPickerOption<Value: Codable & Equatable & Sendable> {
    public var value: Value
    public var title: String
    public var subtitle: String?
    public var iconSystemName: String?

    public init(value: Value, title: String, subtitle: String? = nil, iconSystemName: String? = nil) {
        self.value = value
        self.title = title
        self.subtitle = subtitle
        self.iconSystemName = iconSystemName
    }
}

public struct ConfigPickerElement<Value: Codable & Equatable & Sendable> {
    public typealias Option = ConfigPickerOption<Value>
    public typealias Handler = @MainActor @Sendable (Value) async -> Void

    public var id: AnyHashable
    public let key: ConfigKey<Value>
    public var title: String?
    public var subtitle: String?
    public var iconSystemName: String?
    public var options: [Option]
    public var handler: Handler?
    public var isVisible: Bool

    public init(
        id: AnyHashable,
        key: ConfigKey<Value>,
        title: String? = nil,
        subtitle: String? = nil,
        iconSystemName: String? = nil,
        options: [Option],
        handler: Handler? = nil,
        isVisible: Bool = true
    ) {
        self.id = id
        self.key = key
        self.title = title
        self.subtitle = subtitle
        self.iconSystemName = iconSystemName
        self.options = options
        self.handler = handler
        self.isVisible = isVisible
    }
}

public struct AnyConfigPickerElement {
    public struct Option {
        public var id: AnyHashable
        public var title: String
        public var subtitle: String?
        public var iconSystemName: String?
        public var rawValue: ConfigurableKitAnyCodable
        public var isSelected: () -> Bool
        public var select: () -> Void

        public init(
            id: AnyHashable,
            title: String,
            subtitle: String? = nil,
            iconSystemName: String? = nil,
            rawValue: ConfigurableKitAnyCodable,
            isSelected: @escaping () -> Bool,
            select: @escaping () -> Void
        ) {
            self.id = id
            self.title = title
            self.subtitle = subtitle
            self.iconSystemName = iconSystemName
            self.rawValue = rawValue
            self.isSelected = isSelected
            self.select = select
        }
    }

    public var id: AnyHashable
    public var title: String?
    public var subtitle: String?
    public var iconSystemName: String?
    public var displayValue: () -> String
    public var options: [Option]
    public var isVisible: Bool
    public var storage: CodableStorage
    public var valuePublisher: AnyPublisher<String, Never>

    public init(
        id: AnyHashable,
        title: String?,
        subtitle: String?,
        iconSystemName: String?,
        displayValue: @escaping () -> String,
        options: [Option],
        isVisible: Bool = true,
        storage: CodableStorage,
        valuePublisher: AnyPublisher<String, Never>
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.iconSystemName = iconSystemName
        self.displayValue = displayValue
        self.options = options
        self.isVisible = isVisible
        self.storage = storage
        self.valuePublisher = valuePublisher
    }
}

@MainActor
extension ConfigPickerElement {
    func erase(using store: ConfigStore) -> AnyConfigPickerElement {
        let keyValueStorage: KeyValueStorage
        if let keyValueStore = store as? KeyValueConfigStore {
            keyValueStorage = keyValueStore.storage
        } else if let keyValueStore = ConfigurableKit.configStore as? KeyValueConfigStore {
            keyValueStorage = keyValueStore.storage
        } else {
            keyValueStorage = ConfigurableKit.storage
        }

        let codableStorage = CodableStorage(
            key: key.rawValue,
            defaultValue: ConfigurableKitAnyCodable(key.defaultValue),
            storage: keyValueStorage
        )

        let displayValue: () -> String = {
            let currentValue = store.value(for: key)
            if let match = options.first(where: { $0.value == currentValue }) {
                return match.title
            }
            return String(describing: currentValue)
        }

        let optionNodes: [AnyConfigPickerElement.Option] = options.enumerated().map { index, option in
            let optionId = AnyHashable("\(id)-\(index)")
            return AnyConfigPickerElement.Option(
                id: optionId,
                title: option.title,
                subtitle: option.subtitle,
                iconSystemName: option.iconSystemName,
                rawValue: ConfigurableKitAnyCodable(option.value),
                isSelected: {
                    let current = store.value(for: key)
                    return current == option.value
                },
                select: { [store, handler, key, optionValue = option.value] in
                    do {
                        try store.writeValue(optionValue, for: key)
                    } catch {
                        assertionFailure("Failed to update picker value for \(key.rawValue): \(error)")
                    }
                    if let handler {
                        Task { @MainActor in
                            await handler(optionValue)
                        }
                    }
                }
            )
        }

        return AnyConfigPickerElement(
            id: id,
            title: title,
            subtitle: subtitle,
            iconSystemName: iconSystemName,
            displayValue: displayValue,
            options: optionNodes,
            isVisible: isVisible,
            storage: codableStorage,
            valuePublisher: store.publisherWithDefault(for: key)
                .map { current in
                    if let match = options.first(where: { $0.value == current }) {
                        return match.title
                    }
                    return String(describing: current)
                }
                .eraseToAnyPublisher()
        )
    }
}
