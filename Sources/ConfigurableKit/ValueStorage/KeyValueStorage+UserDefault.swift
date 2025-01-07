//
//  KeyValueStorage+UserDefault.swift
//  TRApp
//
//  Created by 秋星桥 on 2024/2/13.
//

import Combine

import Foundation

open class UserDefaultKeyValueStorage: KeyValueStorage {
    public init(suite _: UserDefaults) {}

    public func value(forKey: String) -> Data? {
        UserDefaults.standard.data(forKey: forKey)
    }

    public func setValue(_ data: Data?, forKey: String) {
        UserDefaults.standard.set(data, forKey: forKey)
        valueUpdatePublisher.send((forKey, data))
    }

    public static var valueUpdatePublisher: PassthroughSubject<(String, Data?), Never> = .init()
}
