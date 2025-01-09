//
//  ConfigurableKit.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 2025/1/5.
//

import Combine
import Foundation
import UIKit

public enum ConfigurableKit {
    public static var storage: KeyValueStorage = UserDefaultKeyValueStorage(suite: .standard) {
        didSet {
            assert(UIApplication.shared.delegate == nil)
        }
    }

    #if DEBUG
        public static func printEveryValueChange() {
            type(of: storage).printEveryValueChange()
        }
    #endif

    public static func set(
        value: (some Codable)?,
        forKey key: String,
        storage: KeyValueStorage = storage
    ) {
        let data = CodableStorage.encode(value: .init(value))
        storage.setValue(data, forKey: key)
    }

    public static func value<T: Codable>(
        forKey key: String,
        defaultValue: T,
        storage: KeyValueStorage
    ) -> T {
        value(forKey: key, storage: storage) ?? defaultValue
    }

    public static func value<T: Codable>(forKey key: String, storage: KeyValueStorage) -> T? {
        let data = storage.value(forKey: key) ?? .init()
        let currentValue: T? = try? CodableStorage.decode(data: data)?.decodingValue()
        return currentValue
    }

    /// Receive value immediately and it's update in the future
    /// - Parameters:
    ///   - key: String value representing the key
    ///   - type: Expected type to be decoded
    ///   - storage: Value must be set via this storage
    /// - Returns: A publisher that will emit the value immediately and also when the value is updated
    public static func publisher<T: Codable>(
        forKey key: String,
        type _: T.Type,
        storage: KeyValueStorage = storage
    ) -> AnyPublisher<T?, Never> {
        let data = storage.value(forKey: key) ?? .init()
        let currentValue: T? = try? CodableStorage.decode(data: data)?.decodingValue()
        let firstValuePublisher = Just(currentValue).eraseToAnyPublisher()
        let updateValuePublisher = storage.valueUpdatePublisher
            .filter { $0.0 == key }
            .map(\.1)
            .map { data -> T? in
                if let data, let value: T? = try? CodableStorage.decode(data: data)?.decodingValue() {
                    return value
                } else {
                    return nil
                }
            }
            .eraseToAnyPublisher()
        return Publishers.Merge(firstValuePublisher, updateValuePublisher).eraseToAnyPublisher()
    }
}
