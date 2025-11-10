//
//  ConfigKey.swift
//  ConfigurableKit
//
//  Created by GPT-5 Codex on 2025/11/10.
//

import Foundation

public struct ConfigKey<Value: Codable & Sendable>: Sendable {
    public typealias Validator = @Sendable (Value) throws -> Value

    public let rawValue: String
    public let defaultValue: Value
    public let store: ConfigStore?
    public let description: String?

    private let validator: Validator?

    public init(
        _ rawValue: String,
        defaultValue: Value,
        store: ConfigStore? = nil,
        description: String? = nil,
        validator: Validator? = nil
    ) {
        self.rawValue = rawValue
        self.defaultValue = defaultValue
        self.store = store
        self.description = description
        self.validator = validator
    }
}

extension ConfigKey {
    func validate(_ value: Value) throws -> Value {
        guard let validator else {
            return value
        }
        return try validator(value)
    }

    func resolvedStore(default defaultStore: ConfigStore) -> ConfigStore {
        store ?? defaultStore
    }
}
