#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    import AppKit

    open class ConfigurableActionView: ConfigurableView, NSGestureRecognizerDelegate {
        open var actionBlock: @MainActor (CKViewController) async -> Void

        open lazy var pressGesture: NSPressGestureRecognizer = {
            let gesture = NSPressGestureRecognizer(target: self, action: #selector(viewPressed(_:)))
            gesture.minimumPressDuration = 0
            gesture.delegate = self
            return gesture
        }()

        open lazy var tapGesture: NSClickGestureRecognizer = {
            let gesture = NSClickGestureRecognizer(target: self, action: #selector(openItem))
            gesture.delegate = self
            return gesture
        }()

        open var imageView: NSImageView {
            contentView as! NSImageView
        }

        open var isHighlighted: Bool = false {
            didSet {
                guard oldValue != isHighlighted else { return }
                NSAnimationContext.runAnimationGroup { context in
                    context.duration = 0.1
                    animator().alphaValue = isHighlighted ? 0.5 : 1
                }
            }
        }

        public init(responseEverywhere: Bool = true, actionBlock: @escaping (@Sendable (CKViewController) async -> Void) = { _ in }) {
            self.actionBlock = actionBlock

            super.init(frame: .zero)
            contentView.wantsLayer = true

            if responseEverywhere {
                addGestureRecognizer(tapGesture)
                addGestureRecognizer(pressGesture)
            } else {
                imageView.addGestureRecognizer(tapGesture)
                imageView.addGestureRecognizer(pressGesture)
            }
        }

        @available(*, unavailable)
        public required init?(coder _: NSCoder) {
            fatalError()
        }

        override open class func createContentView() -> NSView {
            let view = EasyHitImageView()
            view.imageScaling = .scaleProportionallyUpOrDown
            configure(imageView: view)
            return view
        }

        open class func configure(imageView: NSImageView) {
            imageView.image = NSImage(systemSymbolName: "arrow.right.circle.fill", accessibilityDescription: nil)
            imageView.contentTintColor = .accent
        }

        @objc open func viewPressed(_ gesture: NSPressGestureRecognizer) {
            if gesture.state == .began {
                isHighlighted = true
            } else if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
                isHighlighted = false
            }
        }

        open func gestureRecognizer(_: NSGestureRecognizer, shouldRecognizeSimultaneouslyWith _: NSGestureRecognizer) -> Bool {
            true
        }

        @objc open func openItem() {
            isHighlighted = false
            guard let parentViewController else {
                assertionFailure("ConfigurableActionView requires a parent view controller to execute actions")
                return
            }
            Task { @MainActor in
                await actionBlock(parentViewController)
            }
        }
    }
#endif
