//
//  ConfigurableObject.swift
//  ConfigurableView
//
//  Created by 秋星桥 on 2025/1/4.
//

import Combine
import ConfigurableKitAnyCodable
import Foundation
import UIKit

enum ReservedKeys: String {
    case prefix = "ConfigurableValue.Reserved"
    case submenu = "ConfigurableValue.Reserved.Submenu"
    case ignored = "ConfigurableValue.Reserved.Ignored"
}

open class ConfigurableObject {
    let icon: String
    let title: String
    let explain: String

    let key: String
    let annotation: AnyAnnotation

    let availabilityRequirement: AvailabilityRequirement?

    @CodableStorage var value: AnyCodable
    public var __value: CodableStorage { _value }

    let onChange: AnyPublisher<AnyCodable, Never>
    var cancellable: Set<AnyCancellable> = []

    public init(
        icon: String,
        title: String,
        explain: String,
        key: String,
        defaultValue: AnyCodable,
        annotation: AnyAnnotation,
        availabilityRequirement: AvailabilityRequirement? = nil,
        storage: KeyValueStorage = ConfigurableKit.storage
    ) {
        self.icon = icon
        self.title = title
        self.explain = explain
        self.key = key
        self.annotation = annotation
        self.availabilityRequirement = availabilityRequirement

        while key.hasPrefix(ReservedKeys.prefix.rawValue) {
            if key == ReservedKeys.submenu.rawValue { break }
            if key == ReservedKeys.ignored.rawValue { break }
            assertionFailure()
            break
        }

        _value = .init(key: key, defaultValue: defaultValue, storage: storage)
        onChange = _value.storage.valueUpdatePublisher
            .filter { $0.0 == key }
            .map { $0.1 ?? .init() }
            .map { CodableStorage.decode(data: $0) ?? .init() }
            .eraseToAnyPublisher()
    }

    @discardableResult
    public func whenValueChanged(to newValue: @escaping (AnyCodable) -> Void) -> Self {
        onChange.sink { newValue($0) }.store(in: &cancellable)
        return self
    }

    @discardableResult
    public func whenValueChange<T>(type _: T.Type, to newValue: @escaping (T?) -> Void) -> Self {
        onChange.sink { newValue($0.value as? T) }.store(in: &cancellable)
        return self
    }

    @discardableResult
    public func whenValueChange<T: Equatable>(type _: T.Type, to newValue: @escaping (T?) -> T?) -> Self {
        onChange.sink { [weak self] input in
            let typedInput = input.value as? T
            let overwrite = newValue(typedInput)
            guard typedInput != overwrite else { return }
            self?.value = .init(overwrite)
        }.store(in: &cancellable)
        return self
    }
}

public extension ConfigurableObject {
    convenience init(
        icon: String,
        title: String,
        explain: String,
        key: String,
        defaultValue: AnyCodable,
        annotation: Annotation,
        availabilityRequirement: AvailabilityRequirement? = nil,
        storage: KeyValueStorage = ConfigurableKit.storage
    ) {
        self.init(
            icon: icon,
            title: title,
            explain: explain,
            key: key,
            defaultValue: defaultValue,
            annotation: annotation.mapObject,
            availabilityRequirement: availabilityRequirement,
            storage: storage
        )
    }

    convenience init(
        icon: String,
        title: String,
        explain: String,
        key: String,
        defaultValue: some Codable,
        annotation: AnyAnnotation,
        availabilityRequirement: AvailabilityRequirement? = nil,
        storage: KeyValueStorage = ConfigurableKit.storage
    ) {
        self.init(
            icon: icon,
            title: title,
            explain: explain,
            key: key,
            defaultValue: .init(defaultValue),
            annotation: annotation,
            availabilityRequirement: availabilityRequirement,
            storage: storage
        )
    }

    convenience init(
        icon: String,
        title: String,
        explain: String,
        key: String,
        defaultValue: some Codable,
        annotation: Annotation,
        availabilityRequirement: AvailabilityRequirement? = nil,
        storage: KeyValueStorage = ConfigurableKit.storage
    ) {
        self.init(
            icon: icon,
            title: title,
            explain: explain,
            key: key,
            defaultValue: .init(defaultValue),
            annotation: annotation.mapObject,
            availabilityRequirement: availabilityRequirement,
            storage: storage
        )
    }

    convenience init(
        icon: String,
        title: String,
        explain: String,
        ephemeralAnnotation: AnyAnnotation,
        availabilityRequirement: AvailabilityRequirement? = nil
    ) {
        self.init(
            icon: icon,
            title: title,
            explain: explain,
            key: ReservedKeys.submenu.rawValue,
            defaultValue: "ConfigurableValue.IgnoredValue",
            annotation: ephemeralAnnotation,
            availabilityRequirement: availabilityRequirement,
            storage: ConfigurableKit.storage
        )
    }

    convenience init(
        icon: String,
        title: String,
        explain: String,
        ephemeralAnnotation: Annotation,
        availabilityRequirement: AvailabilityRequirement? = nil
    ) {
        self.init(
            icon: icon,
            title: title,
            explain: explain,
            ephemeralAnnotation: ephemeralAnnotation.mapObject,
            availabilityRequirement: availabilityRequirement
        )
    }

    convenience init(customView: @escaping () -> (UIView)) {
        self.init(
            icon: "",
            title: "",
            explain: "",
            ephemeralAnnotation: CustomViewAnnotation(view: customView)
        )
    }
}
