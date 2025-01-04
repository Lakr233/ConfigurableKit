//
//  ConfigurableView+Boolean.swift
//  TRApp
//
//  Created by 82Flex on 2024/9/14.
//

import Combine
import ConfigurableKitAnyCodable
import UIKit

class ConfigurableBooleanView: ConfigurableValueView {
    var switchView: UISwitch { contentView as! UISwitch }

    override init(storage: CodableStorage) {
        super.init(storage: storage)

        switchView.onTintColor = .accent
        switchView.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }

    override class func createContentView() -> UIView {
        UISwitch()
    }

    override func updateValue(_ value: AnyCodable) {
        super.updateValue(value)
        switchView.setOn(value.value as? Bool ?? false, animated: true)
    }

    @objc func valueChanged() {
        value = .init(switchView.isOn)
    }
}
