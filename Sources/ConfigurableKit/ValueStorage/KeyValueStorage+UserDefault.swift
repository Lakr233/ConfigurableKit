//
//  KeyValueStorage+UserDefault.swift
//  TRApp
//
//  Created by 秋星桥 on 2024/2/13.
//

import Combine
import Foundation

open nonisolated class UserDefaultKeyValueStorage: KeyValueStorage {
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
        valueUpdatePublisher.send((forKey, data))

        #if DEBUG
            if printValueChange {
                var objectText = String(describing: data)
                if let text = String(data: data ?? .init(), encoding: .utf8)?
                    .trimmingCharacters(in: .whitespacesAndNewlines),
                    !text.isEmpty
                { objectText = text }
                // if is a json object, format it
                if let json = try? JSONSerialization.jsonObject(with: data ?? .init(), options: []),
                   let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
                   let jsonText = String(data: jsonData, encoding: .utf8)?
                   .trimmingCharacters(in: .whitespacesAndNewlines),
                   !jsonText.isEmpty
                { objectText = jsonText }
                print("[ConfiguableKit] set value for key: \(prefixedKey) with object: \(objectText)")
            }
        #endif
    }

    #if DEBUG
        private var printValueChange: Bool { Self.printValueChange }
        private nonisolated(unsafe) static var printValueChange: Bool = false
        public static func printEveryValueChange() {
            printValueChange = true
        }
    #endif

    public nonisolated(unsafe) static let valueUpdatePublisher: PassthroughSubject<(String, Data?), Never> = .init()
}
