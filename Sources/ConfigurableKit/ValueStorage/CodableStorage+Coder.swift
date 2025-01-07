//
//  CodableStorage+Coder.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 2025/1/5.
//

import Foundation

extension CodableStorage {
    static let jsonEncoder = JSONEncoder()
    static let jsonDecoder = JSONDecoder()

    static func encode(value: ConfigurableKitAnyCodable) -> Data? {
        try? jsonEncoder.encode(value)
    }

    static func decode(data: Data) -> ConfigurableKitAnyCodable? {
        try? jsonDecoder.decode(ConfigurableKitAnyCodable.self, from: data)
    }

    static func read(key: String, storage: KeyValueStorage) -> ConfigurableKitAnyCodable? {
        guard let data = storage.value(forKey: key) else {
            return nil
        }
        return decode(data: data)
    }

    static func write(_ value: ConfigurableKitAnyCodable, forKey key: String, storage: KeyValueStorage) {
        if let data = encode(value: value) {
            storage.setValue(data, forKey: key)
        } else {
            assertionFailure()
            storage.setValue(nil, forKey: key)
        }
    }
}
