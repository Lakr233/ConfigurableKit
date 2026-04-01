#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    import AppKit

    public enum ConfigurablePagePresentationStyle {
        case push
        case modal(style: CKModalPresentationStyle = .automatic, embedInNavigationController: Bool = true)
    }

    open class ConfigurablePageView: ConfigurableActionView {
        let page: () -> CKViewController?
        let presentationStyle: ConfigurablePagePresentationStyle

        public init(
            page: @escaping () -> CKViewController?,
            presentationStyle: ConfigurablePagePresentationStyle = .push
        ) {
            self.page = page
            self.presentationStyle = presentationStyle

            super.init(responseEverywhere: true)
            actionBlock = { [weak self] parentViewController in
                guard let self, let page = self.page() else { return }
                page.title = titleLabel.stringValue

                switch presentationStyle {
                case .push:
                    parentViewController.ckPush(page, animated: true)
                case let .modal(style, _):
                    parentViewController.ckPresentModal(page, style: style, animated: true)
                }
            }
        }

        override open class func configure(imageView: NSImageView) {
            imageView.image = NSImage(systemSymbolName: "chevron.right", accessibilityDescription: nil)
            imageView.contentTintColor = .secondaryLabelColor
        }
    }
#endif
