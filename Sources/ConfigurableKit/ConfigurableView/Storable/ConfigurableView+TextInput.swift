//
//  ConfigurableView+TextInput.swift
//  ConfigurableKit
//
//  A storable view that presents an inline UITextField for string editing.
//

import Combine
import UIKit

open class ConfigurableTextInputView: ConfigurableStorableView {
    public let placeholder: String

    open var textField: UITextField {
        contentView as! UITextField
    }

    public init(storage: CodableStorage, placeholder: String) {
        self.placeholder = placeholder
        super.init(storage: storage)

        textField.textAlignment = .right
        textField.font = .preferredFont(forTextStyle: .body)
        textField.adjustsFontForContentSizeCategory = true
        textField.placeholder = placeholder
        textField.returnKeyType = .done
        textField.autocorrectionType = .no
        textField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        textField.addTarget(self, action: #selector(editingDidEnd), for: .editingDidEndOnExit)
    }

    override open class func createContentView() -> UIView {
        let tf = UITextField()
        tf.setContentHuggingPriority(.defaultLow, for: .horizontal)
        tf.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return tf
    }

    override open func updateValue() {
        super.updateValue()
        let text: String = value.decodingValue(defaultValue: "")
        if textField.text != text {
            textField.text = text
        }
    }

    @objc open func editingChanged() {
        value = .init(textField.text ?? "")
    }

    @objc open func editingDidEnd() {
        textField.resignFirstResponder()
    }
}
