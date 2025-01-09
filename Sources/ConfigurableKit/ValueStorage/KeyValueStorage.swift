//
//  KeyValueStorage.swift
//  TRApp
//
//  Created by Lessica on 2024/3/22.
//

import Combine
import Foundation

public protocol KeyValueStorage: AnyObject {
    #if DEBUG
        static func printEveryValueChange()
    #endif

    func value(forKey: String) -> Data?
    func setValue(_ data: Data?, forKey: String)

    var valueUpdatePublisher: PassthroughSubject<(String, Data?), Never> { get }
    static var valueUpdatePublisher: PassthroughSubject<(String, Data?), Never> { get }
}

public extension KeyValueStorage {
    var valueUpdatePublisher: PassthroughSubject<(String, Data?), Never> {
        Self.valueUpdatePublisher
    }
}
