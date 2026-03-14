//
//  ConfigurableObject.swift
//  ConfigurableView
//
//  Created by 秋星桥 on 2025/1/4.
//

import Combine
import Foundation
import UIKit

enum ReservedKeys: String {
    case prefix = "ConfigurableValue.Reserved"
    case submenu = "ConfigurableValue.Reserved.Submenu"
    case ignored = "ConfigurableValue.Reserved.Ignored"
}

open class ConfigurableObject {
    public var icon: String {
        didSet { metadataSubject.send(()) }
    }

    public var title: String.LocalizationValue {
        didSet { metadataSubject.send(()) }
    }

    public var explain: String.LocalizationValue {
        didSet { metadataSubject.send(()) }
    }

    public let key: String
    public let annotation: AnyAnnotation

    public let availabilityRequirement: AvailabilityRequirement?

    @CodableStorage
    var value: ConfigurableKitAnyCodable
    public var valueStorage: CodableStorage {
        _value
    }

    public let onChange: AnyPublisher<ConfigurableKitAnyCodable, Never>

    private let metadataSubject = PassthroughSubject<Void, Never>()
    public var metadataDidChange: AnyPublisher<Void, Never> {
        metadataSubject.eraseToAnyPublisher()
    }

    public var cancellable: Set<AnyCancellable> = []

    // MARK: - Primary Init (storable value, protocol-based annotation)

    public init(
        icon: String = "",
        title: String.LocalizationValue,
        explain: String.LocalizationValue = "",
        key: String,
        defaultValue: some Codable,
        annotation: some AnnotationProtocol,
        availabilityRequirement: AvailabilityRequirement? = nil,
        storage: KeyValueStorage = ConfigurableKit.storage
    ) {
        self.icon = icon
        self.title = title

        var buildExplain: String.LocalizationValue = explain
        if String(localized: explain).isEmpty, let submenu = annotation as? SubmenuAnnotation {
            let titles = submenu.children().map { String(localized: $0.title) }
            buildExplain = String.LocalizationValue(stringLiteral: titles.joined(separator: " / "))
        }
        self.explain = buildExplain

        self.key = key
        self.annotation = annotation
        self.availabilityRequirement = availabilityRequirement

        if key.hasPrefix(ReservedKeys.prefix.rawValue),
           key != ReservedKeys.submenu.rawValue,
           key != ReservedKeys.ignored.rawValue
        {
            assertionFailure("key uses reserved prefix: \(key)")
        }

        _value = .init(key: key, defaultValue: .init(defaultValue), storage: storage)
        onChange = _value.storage.valueUpdatePublisher
            .filter { $0.0 == key }
            .map { $0.1 ?? .init() }
            .map { CodableStorage.decode(data: $0) ?? .init() }
            .eraseToAnyPublisher()
    }

    deinit {
        cancellable.forEach { $0.cancel() }
        cancellable.removeAll()
    }

    public func publisher<T: Codable>(forKey key: String, type _: T) -> AnyPublisher<T?, Never> {
        ConfigurableKit.publisher(forKey: key, type: T.self, storage: valueStorage.storage)
    }

    @discardableResult
    public func whenValueChanged(to newValue: @escaping (ConfigurableKitAnyCodable) -> Void) -> Self {
        onChange.sink { newValue($0) }.store(in: &cancellable)
        return self
    }

    @discardableResult
    public func whenValueChange<T: Codable>(type _: T.Type, to newValue: @escaping (T?) -> Void) -> Self {
        onChange.sink { newValue(try? $0.decodingValue()) }.store(in: &cancellable)
        return self
    }

    @discardableResult
    public func whenValueChange<T: Equatable & Codable>(type _: T.Type, to newValue: @escaping (T?) -> T?) -> Self {
        onChange.sink { [weak self] input in
            let typedInput: T? = try? input.decodingValue()
            let overwrite = newValue(typedInput)
            guard typedInput != overwrite else { return }
            self?.value = .init(overwrite)
        }.store(in: &cancellable)
        return self
    }
}

// MARK: - Annotation Enum Convenience Inits (for dot-syntax support)

public extension ConfigurableObject {
    convenience init(
        icon: String = "",
        title: String.LocalizationValue,
        explain: String.LocalizationValue = "",
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
            defaultValue: defaultValue,
            annotation: annotation.createAnnotation(),
            availabilityRequirement: availabilityRequirement,
            storage: storage
        )
    }

    convenience init(
        icon: String = "",
        title: String.LocalizationValue,
        explain: String.LocalizationValue = "",
        ephemeralAnnotation: Annotation,
        availabilityRequirement: AvailabilityRequirement? = nil
    ) {
        self.init(
            icon: icon,
            title: title,
            explain: explain,
            key: ReservedKeys.submenu.rawValue,
            defaultValue: "ConfigurableValue.IgnoredValue",
            annotation: ephemeralAnnotation.createAnnotation(),
            availabilityRequirement: availabilityRequirement,
            storage: ConfigurableKit.storage
        )
    }
}

// MARK: - Protocol-based Ephemeral & Custom View Inits

public extension ConfigurableObject {
    convenience init(
        icon: String = "",
        title: String.LocalizationValue,
        explain: String.LocalizationValue = "",
        ephemeralAnnotation: some AnnotationProtocol,
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

    convenience init(customView: @escaping () -> (UIView)) {
        self.init(
            icon: "",
            title: "",
            explain: "",
            ephemeralAnnotation: CustomAnnotation(view: customView)
        )
    }
}
