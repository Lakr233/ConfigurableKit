#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    import AppKit

    open class ConfigurableLinkView: ConfigurableView {
        let url: URL

        open var button: EasyHitButton {
            contentView as! EasyHitButton
        }

        public init(buttonTitle: String.LocalizationValue, url: URL) {
            self.url = url

            super.init(frame: .zero)

            let buttonTitleString = String(localized: buttonTitle)
            button.attributedTitle = NSAttributedString(string: buttonTitleString, attributes: [
                .foregroundColor: NSColor.accent,
                .font: NSFont.systemFont(ofSize: NSFont.systemFontSize).semibold,
                .underlineStyle: NSUnderlineStyle.single.rawValue,
            ])
            button.target = self
            button.action = #selector(openURL)
            button.alignment = .right
            button.isBordered = false
        }

        @_disfavoredOverload
        public convenience init(buttonTitle: String, url: URL) {
            self.init(buttonTitle: String.LocalizationValue(buttonTitle), url: url)
        }

        @available(*, unavailable)
        public required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override open class func createContentView() -> NSView {
            EasyHitButton(title: "", target: nil, action: nil)
        }

        @objc open func openURL() {
            NSWorkspace.shared.open(url)
        }
    }
#endif
