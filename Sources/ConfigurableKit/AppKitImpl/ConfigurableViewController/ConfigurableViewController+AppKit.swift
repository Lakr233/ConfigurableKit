#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    import AppKit
    import Combine

    open class ConfigurableViewController: StackScrollController {
        public let manifest: ConfigurableManifest

        public weak var delegate: ConfigurableViewControllerDelegate?

        public init(manifest: ConfigurableManifest) {
            self.manifest = manifest
            super.init(nibName: nil, bundle: nil)
            title = String(localized: manifest.title)
        }

        @available(*, unavailable)
        public required init?(coder _: NSCoder) {
            fatalError()
        }

        public var cancellables = Set<AnyCancellable>()
        public var onDeinit: (@Sendable () -> Void)?

        deinit {
            onDeinit?()
        }

        override open func viewDidLoad() {
            super.viewDidLoad()
            delegate?.configurableViewControllerDidLoad(self)
        }

        override open func viewWillAppear() {
            super.viewWillAppear()
            delegate?.configurableViewControllerWillAppear(self)
        }

        override open func viewDidAppear() {
            super.viewDidAppear()
            delegate?.configurableViewControllerDidAppear(self)
        }

        override open func setupContentViews() {
            super.setupContentViews()
            stackView.addArrangedSubview(SeparatorView())

            let views = manifest.list.compactMap { $0.createView() }
            for view in views {
                stackView.addArrangedSubviewWithMargin(view)
                stackView.addArrangedSubview(SeparatorView())
            }

            stackView.addArrangedSubviewWithMargin(manifest.footer) { input in
                input.left = 0
                input.right = 0
            }
        }
    }
#endif
