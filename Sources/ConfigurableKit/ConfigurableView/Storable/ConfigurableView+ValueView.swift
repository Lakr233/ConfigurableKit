//
//  ConfigurableView+ValueView.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 2025/1/5.
//

import Combine
import ConfigurableKitAnyCodable
import UIKit

open class ConfigurableValueView: ConfigurableView {
    @CodableStorage public var value: AnyCodable

    public init(storage: CodableStorage) {
        _value = .init(
            key: storage.key,
            defaultValue: storage.defaultValue,
            storage: storage.storage
        )

        super.init()

        storage.storage.valueUpdatePublisher
            .filter { $0.0 == storage.key }
            .map { $0.1 ?? .init() }
            .map { data -> AnyCodable in CodableStorage.decode(data: data) ?? false }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.updateValue(value)
            }
            .store(in: &cancellables)
        updateValue(value)
    }

    @available(*, unavailable)
    public required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open class func createContentView() -> UIView {
        UISwitch()
    }

    open func updateValue(_ value: AnyCodable) {
        _ = value // stub
    }
}
