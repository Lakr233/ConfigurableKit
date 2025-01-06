//
//  ConfigurableKit.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 2025/1/5.
//

import Combine
import Foundation
import UIKit

@_exported import ConfigurableKitAnyCodable

public enum ConfigurableKit {
    public static var storage: KeyValueStorage = UserDefaultKeyValueStorage(suite: .standard) {
        didSet {
            assert(UIApplication.shared.delegate == nil)
        }
    }

    public static func publisher<T: Codable>(
        forKey key: String,
        type _: T.Type,
        storage: KeyValueStorage = storage
    ) -> AnyPublisher<T?, Never> {
        let data = storage.value(forKey: key) ?? .init()
        let currentValue = CodableStorage.decode(data: data)?.value as? T
        let firstValuePublisher = Just(currentValue).eraseToAnyPublisher()
        let updateValuePublisher = storage.valueUpdatePublisher
            .filter { $0.0 == key }
            .map(\.1)
            .map { data -> T? in
                if let data, let value = CodableStorage.decode(data: data)?.value as? T {
                    return value
                } else {
                    return nil
                }
            }
            .eraseToAnyPublisher()
        return Publishers.Merge(firstValuePublisher, updateValuePublisher).eraseToAnyPublisher()
    }
}
