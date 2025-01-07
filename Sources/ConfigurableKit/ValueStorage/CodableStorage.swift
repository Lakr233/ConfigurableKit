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
