//
//  KeyValueConfigStore.swift
//  ConfigurableKit
//
//  Created by GPT-5 Codex on 2025/11/10.
//

@preconcurrency import Combine
import Foundation

@MainActor
final class KeyValueConfigStore: ConfigStore {
    let storage: KeyValueStorage

    init(storage: KeyValueStorage) {
        self.storage = storage
    }

    func readValue<Value: Codable & Sendable>(for key: ConfigKey<Value>) -> Value? {
        guard let data = storage.value(forKey: key.rawValue) else {
            return nil
        }
        guard let anyCodable = CodableStorage.decode(data: data) else {
            return nil
        }
        do {
            return try anyCodable.decodingValue()
        } catch {
            assertionFailure("ConfigStore decode failed for key \(key.rawValue): \(error)")
            return nil
        }
    }

    func writeValue<Value: Codable & Sendable>(_ value: Value?, for key: ConfigKey<Value>) throws {
        guard let value else {
            storage.setValue(nil, forKey: key.rawValue)
            return
        }

        let validated: Value
        do {
            validated = try key.validate(value)
        } catch {
            throw ConfigStoreError.validationFailed(key.rawValue, underlying: error)
        }

        let encoded = ConfigurableKitAnyCodable(validated)
        guard let data = CodableStorage.encode(value: encoded) else {
            throw ConfigStoreError.encodingFailed(key.rawValue)
        }
        storage.setValue(data, forKey: key.rawValue)
    }

    func publisher<Value: Codable & Sendable>(for key: ConfigKey<Value>) -> AnyPublisher<Value?, Never> {
        storage.valueUpdatePublisher
            .filter { $0.0 == key.rawValue }
            .map { _, data -> Value? in
                guard let data else {
                    return nil
                }
                guard let anyCodable = CodableStorage.decode(data: data) else {
                    return nil
                }
                return try? anyCodable.decodingValue()
            }
            .eraseToAnyPublisher()
    }
}
