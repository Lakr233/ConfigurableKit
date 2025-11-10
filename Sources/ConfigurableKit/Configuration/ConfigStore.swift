//
//  ConfigStore.swift
//  ConfigurableKit
//
//  Created by GPT-5 Codex on 2025/11/10.
//

@preconcurrency import Combine
import Foundation

@MainActor
public protocol ConfigStore: AnyObject, Sendable {
    func readValue<Value: Codable & Sendable>(for key: ConfigKey<Value>) -> Value?
    func writeValue<Value: Codable & Sendable>(_ value: Value?, for key: ConfigKey<Value>) throws
    func publisher<Value: Codable & Sendable>(for key: ConfigKey<Value>) -> AnyPublisher<Value?, Never>
}

@MainActor
public extension ConfigStore {
    func value<Value: Codable & Sendable>(for key: ConfigKey<Value>) -> Value {
        if let value: Value = readValue(for: key) {
            return value
        }
        return key.defaultValue
    }

    func publisherWithDefault<Value: Codable & Sendable>(for key: ConfigKey<Value>) -> AnyPublisher<Value, Never> {
        publisher(for: key)
            .map { $0 ?? key.defaultValue }
            .prepend(value(for: key))
            .eraseToAnyPublisher()
    }
}

@MainActor
public enum ConfigStoreError: Error {
    case encodingFailed(String)
    case decodingFailed(String)
    case validationFailed(String, underlying: Error)
}
