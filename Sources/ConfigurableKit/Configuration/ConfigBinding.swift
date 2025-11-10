//
//  ConfigBinding.swift
//  ConfigurableKit
//
//  Created by GPT-5 Codex on 2025/11/10.
//

@preconcurrency import Combine
import Foundation

@propertyWrapper
@MainActor
public struct ConfigBinding<Value: Codable & Sendable> {
    private let key: ConfigKey<Value>
    private let store: ConfigStore

    public init(_ key: ConfigKey<Value>, store: ConfigStore? = nil) {
        self.key = key
        self.store = key.resolvedStore(default: store ?? ConfigurableKit.configStore)
    }

    public var wrappedValue: Value {
        get {
            store.value(for: key)
        }
        nonmutating set {
            do {
                try store.writeValue(newValue, for: key)
            } catch {
                assertionFailure("ConfigBinding failed to write value for \(key.rawValue): \(error)")
            }
        }
    }

    public var projectedValue: Projection {
        Projection(key: key, store: store)
    }

    @MainActor
    public struct Projection {
        private let key: ConfigKey<Value>
        private let store: ConfigStore

        fileprivate init(key: ConfigKey<Value>, store: ConfigStore) {
            self.key = key
            self.store = store
        }

        public func publisher() -> AnyPublisher<Value, Never> {
            store.publisherWithDefault(for: key)
        }

        public func optionalPublisher() -> AnyPublisher<Value?, Never> {
            store.publisher(for: key)
                .prepend(store.readValue(for: key))
                .eraseToAnyPublisher()
        }

        public func stream(
            bufferingPolicy: AsyncStream<Value>.Continuation.BufferingPolicy = .bufferingNewest(1)
        ) -> AsyncStream<Value> {
            let asyncValues = publisher().values
            return AsyncStream(bufferingPolicy: bufferingPolicy) { continuation in
                let storage = ContinuationBox(continuation)
                let task = Task {
                    for await value in asyncValues {
                        storage.continuation.yield(value)
                    }
                }
                continuation.onTermination = { _ in
                    task.cancel()
                }
            }
        }

        @discardableResult
        public func set(_ value: Value) -> Result<Void, Error> {
            do {
                try store.writeValue(value, for: key)
                return .success(())
            } catch {
                return .failure(error)
            }
        }

        @discardableResult
        public func set(_ value: Value?) -> Result<Void, Error> {
            do {
                try store.writeValue(value, for: key)
                return .success(())
            } catch {
                return .failure(error)
            }
        }
    }
}

private final class ContinuationBox<Value>: @unchecked Sendable {
    let continuation: AsyncStream<Value>.Continuation

    init(_ continuation: AsyncStream<Value>.Continuation) {
        self.continuation = continuation
    }
}
