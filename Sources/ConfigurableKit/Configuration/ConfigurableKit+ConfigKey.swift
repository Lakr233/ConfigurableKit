//
//  ConfigurableKit+ConfigKey.swift
//  ConfigurableKit
//
//  Created by GPT-5 Codex on 2025/11/10.
//

import Combine
import Foundation

public extension ConfigurableKit {
    static func value<Value: Codable & Sendable>(for key: ConfigKey<Value>, store: ConfigStore? = nil) -> Value {
        let resolvedStore = key.resolvedStore(default: store ?? configStore)
        return resolvedStore.value(for: key)
    }

    static func optionalValue<Value: Codable & Sendable>(for key: ConfigKey<Value>, store: ConfigStore? = nil) -> Value? {
        let resolvedStore = key.resolvedStore(default: store ?? configStore)
        return resolvedStore.readValue(for: key)
    }

    @discardableResult
    static func set<Value: Codable & Sendable>(
        _ value: Value?,
        for key: ConfigKey<Value>,
        store: ConfigStore? = nil
    ) -> Result<Void, Error> {
        let resolvedStore = key.resolvedStore(default: store ?? configStore)
        do {
            try resolvedStore.writeValue(value, for: key)
            return .success(())
        } catch {
            return .failure(error)
        }
    }

    static func publisher<Value: Codable & Sendable>(
        for key: ConfigKey<Value>,
        store: ConfigStore? = nil
    ) -> AnyPublisher<Value, Never> {
        let resolvedStore = key.resolvedStore(default: store ?? configStore)
        return resolvedStore.publisherWithDefault(for: key)
    }

    static func optionalPublisher<Value: Codable & Sendable>(
        for key: ConfigKey<Value>,
        store: ConfigStore? = nil
    ) -> AnyPublisher<Value?, Never> {
        let resolvedStore = key.resolvedStore(default: store ?? configStore)
        return resolvedStore.publisher(for: key)
            .prepend(resolvedStore.readValue(for: key))
            .eraseToAnyPublisher()
    }
}
