#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    import AppKit

    open class ConfigurableToggleView: ConfigurableStorableView {
        private var isApplyingProgrammaticValue = false

        open var switchView: NSSwitch {
            contentView as! NSSwitch
        }

        open var boolValue: Bool {
            get { value.decodingValue(defaultValue: false) }
            set { value = .init(newValue) }
        }

        override public init(storage: CodableStorage) {
            super.init(storage: storage)

            switchView.target = self
            switchView.action = #selector(valueChanged)
        }

        override open class func createContentView() -> NSView {
            NSSwitch()
        }

        override open func updateValue() {
            super.updateValue()

            let targetState: NSControl.StateValue = boolValue ? .on : .off
            guard switchView.state != targetState else { return }

            if window != nil {
                isApplyingProgrammaticValue = true
                switchView.performClick(nil)
                isApplyingProgrammaticValue = false
                if switchView.state != targetState {
                    switchView.state = targetState
                }
            } else {
                switchView.state = targetState
            }
        }

        @objc open func valueChanged() {
            guard !isApplyingProgrammaticValue else { return }
            value = .init(switchView.state == .on)
        }
    }
#endif
