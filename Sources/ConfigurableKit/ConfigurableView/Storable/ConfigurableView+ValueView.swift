//
//  ConfigurableView+ValueView.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 2025/1/5.
//

import Combine
import UIKit

open class ConfigurableValueView: ConfigurableView {
    @CodableStorage public var value: ConfigurableKitAnyCodable

    public init(storage: CodableStorage) {
        _value = .init(
            key: storage.key,
            defaultValue: storage.defaultValue,
            storage: storage.storage
        )

        super.init()

        storage.storage.valueUpdatePublisher
            .filter { $0.0 == storage.key }
            .map { _ in () }
            // delay an update, property wrapper getter and setter requires exclusive access
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateValue()
            }
            .store(in: &cancellables)
        updateValue()
    }

    @available(*, unavailable)
    public required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open class func createContentView() -> UIView {
        UISwitch()
    }

    open func updateValue() {}
}
