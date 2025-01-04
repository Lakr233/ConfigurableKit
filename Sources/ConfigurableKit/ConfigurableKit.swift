//
//  ConfigurableKit.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 2025/1/5.
//

import Foundation

@_exported import ConfigurableKitAnyCodable

public enum ConfigurableKit {
    public static var storage: KeyValueStorage = UserDefaultKeyValueStorage(suite: .standard)
}
