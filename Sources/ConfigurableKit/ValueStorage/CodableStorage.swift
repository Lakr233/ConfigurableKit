//
//  CodableStorage.swift
//  TRApp
//
//  Created by Lessica on 2024/3/22.
//

import Combine
import Foundation

@propertyWrapper
public struct CodableStorage {
    public let key: String
    public let defaultValue: ConfigurableKitAnyCodable
    public var storage: KeyValueStorage

    public init(key: String, defaultValue: ConfigurableKitAnyCodable, storage: KeyValueStorage) {
        self.key = key
        self.defaultValue = defaultValue
        self.storage = storage
    }

    public var wrappedValue: ConfigurableKitAnyCodable {
        get {
            if let value = Self.read(key: key, storage: storage) {
                value
            } else {
                defaultValue
            }
        }
        set {
            Self.write(newValue, forKey: key, storage: storage)
        }
    }
}

@propertyWrapper
@MainActor
public struct BareCodableStorage<T: Codable> {
    public let key: String
    public let defaultValue: T
    public var storage: KeyValueStorage

    public init(key: String, defaultValue: T, storage: KeyValueStorage) {
        self.key = key
        self.defaultValue = defaultValue
        self.storage = storage
    }

    public var wrappedValue: T {
        get {
            let object = CodableStorage.read(key: key, storage: storage) ?? .init()
            return object.decodingValue(defaultValue: defaultValue)
        }
        set {
            CodableStorage.write(.init(newValue), forKey: key, storage: storage)
        }
    }
}

@MainActor
public extension BareCodableStorage {
    init(key: String, defaultValue: T) {
        self.init(key: key, defaultValue: defaultValue, storage: ConfigurableKit.storage)
    }
}
