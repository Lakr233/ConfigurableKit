#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    import AppKit
    import Combine

    open class ConfigurableTextInputView: ConfigurableStorableView, NSTextFieldDelegate {
        public let placeholder: String

        open var textField: NSTextField {
            contentView as! NSTextField
        }

        public init(storage: CodableStorage, placeholder: String) {
            self.placeholder = placeholder
            super.init(storage: storage)

            textField.alignment = .right
            textField.font = .systemFont(ofSize: NSFont.systemFontSize)
            textField.placeholderString = placeholder
            textField.delegate = self
            textField.focusRingType = .none
        }

        override open class func createContentView() -> NSView {
            let tf = NSTextField(string: "")
            tf.setContentHuggingPriority(.defaultLow, for: .horizontal)
            tf.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            return tf
        }

        override open func updateValue() {
            super.updateValue()
            let text: String = value.decodingValue(defaultValue: "")
            if textField.stringValue != text {
                textField.stringValue = text
            }
        }

        open func controlTextDidChange(_: Notification) {
            value = .init(textField.stringValue)
        }

        open func controlTextDidEndEditing(_: Notification) {
            value = .init(textField.stringValue)
        }
    }
#endif
