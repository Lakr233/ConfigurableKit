//
//  SelfIncreaseNumberAnnotation.swift
//  ConfigurableExample
//
//  Created by 秋星桥 on 2025/1/5.
//

import ConfigurableKit

import Foundation
import UIKit

class SelfIncreaseNumberAnnotation: ConfigurableObject.AnnotationProtocol {
    func createView(fromObject object: ConfigurableObject) -> ConfigurableView {
        SelfIncreaseNumberConfigurableView(storage: object.__value)
    }
}

class SelfIncreaseNumberConfigurableView: ConfigurableValueView {
    var button: UIButton { contentView as! UIButton }

    var intValue: Int {
        get { value.decodingValue(defaultValue: 0) }
        set { value = .init(newValue) }
    }

    override init(storage: CodableStorage) {
        super.init(storage: storage)

        button.addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }

    override class func createContentView() -> UIView {
        let button = UIButton()
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }

    override func updateValue() {
        super.updateValue()
        button.setTitle("\(intValue)", for: .normal)
    }

    @objc func tapped() {
        intValue += 1
    }
}
