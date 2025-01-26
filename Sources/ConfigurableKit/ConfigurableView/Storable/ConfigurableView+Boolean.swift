//
//  ConfigurableView+Boolean.swift
//  TRApp
//
//  Created by 82Flex on 2024/9/14.
//

import Combine
import UIKit

open class ConfigurableBooleanView: ConfigurableValueView {
    open var switchView: UISwitch { contentView as! UISwitch }

    open var boolValue: Bool {
        get { value.decodingValue(defaultValue: false) }
        set { value = .init(newValue) }
    }

    override init(storage: CodableStorage) {
        super.init(storage: storage)

        switchView.onTintColor = .accent
        switchView.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }

    override open class func createContentView() -> UIView {
        UISwitch()
    }

    override open func updateValue() {
        super.updateValue()
        switchView.setOn(boolValue, animated: true)
    }

    @objc open func valueChanged() {
        value = .init(switchView.isOn)
    }
}
