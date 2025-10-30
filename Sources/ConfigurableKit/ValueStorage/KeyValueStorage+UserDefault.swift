//
//  KeyValueStorage+UserDefault.swift
//  TRApp
//
//  Created by 秋星桥 on 2024/2/13.
//

import Combine
import Foundation

nonisolated
open class UserDefaultKeyValueStorage: KeyValueStorage {
    let suite: UserDefaults

    public init(suite: UserDefaults) {
        self.suite = suite
    }

    public func value(forKey: String) -> Data? {
        suite.data(forKey: forKey)
    }

    public func setValue(_ data: Data?, forKey: String) {
        suite.set(data, forKey: forKey)
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
                print("[ConfiguableKit] set value for key: \(forKey) with object: \(objectText)")
            }
        #endif
    }

    #if DEBUG
        private var printValueChange: Bool { Self.printValueChange }
        nonisolated(unsafe)
        private static var printValueChange: Bool = false
        public static func printEveryValueChange() {
            printValueChange = true
        }
    #endif

    nonisolated(unsafe)
    public static let valueUpdatePublisher: PassthroughSubject<(String, Data?), Never> = .init()
}
