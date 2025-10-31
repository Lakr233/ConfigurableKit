//
//  KeyValueStorage+UserDefault.swift
//  TRApp
//
//  Created by 秋星桥 on 2024/2/13.
//

@preconcurrency import Combine
import Foundation

open nonisolated class UserDefaultKeyValueStorage: KeyValueStorage {
    public static let valueUpdatePublisher: PassthroughSubject<(String, Data?), Never> = .init()

    let suite: UserDefaults
    let prefix: String?

    public init(suite: UserDefaults, prefix: String? = nil) {
        self.suite = suite
        self.prefix = prefix
    }

    private func prefixedKey(_ key: String) -> String {
        if let prefix {
            return prefix + key
        }
        return key
    }

    public func value(forKey: String) -> Data? {
        suite.data(forKey: prefixedKey(forKey))
    }

    public func setValue(_ data: Data?, forKey: String) {
        let prefixedKey = prefixedKey(forKey)
        suite.set(data, forKey: prefixedKey)

        let valueUpdatePublisher = Self.valueUpdatePublisher
        DispatchQueue.main.async {
            valueUpdatePublisher.send((forKey, data))
        }
    }
}
