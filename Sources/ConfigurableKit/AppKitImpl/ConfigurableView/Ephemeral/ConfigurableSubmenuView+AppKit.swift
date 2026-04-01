#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    import AppKit

    open class ConfigurableSubmenuView: ConfigurableActionView {
        let childrenReader: () -> [ConfigurableObject]

        public init(childrenReader: @escaping () -> [ConfigurableObject]) {
            self.childrenReader = childrenReader

            super.init(responseEverywhere: true)
            actionBlock = { [weak self] parentViewController in
                var titleValue: String.LocalizationValue?
                if let title = self?.titleLabel.stringValue, !title.isEmpty {
                    titleValue = String.LocalizationValue(title)
                }
                let menu = ConfigurableViewController(manifest: .init(title: titleValue, list: childrenReader()))
                parentViewController.ckPush(menu, animated: true)
            }
        }

        override open class func configure(imageView: NSImageView) {
            imageView.image = NSImage(systemSymbolName: "chevron.right", accessibilityDescription: nil)
            imageView.contentTintColor = .secondaryLabelColor
        }
    }
#endif
