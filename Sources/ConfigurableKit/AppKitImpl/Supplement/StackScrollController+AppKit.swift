#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    import AppKit

    open class StackScrollController: NSViewController {
        public let contentView = NSView()
        public let stackView = NSStackView()
        private var stackTopConstraint: NSLayoutConstraint?

        /// How the rows of this page show their explanation, unless a row sets
        /// its own `descriptionStyle`. `nil` (the default) shows the full
        /// explanation, which is what settings pages want. Pages that mostly
        /// show data can pick `.singleLine` or `.hidden` to fit more rows.
        open var descriptionStyle: ConfigurableDescriptionStyle? {
            didSet {
                guard oldValue != descriptionStyle, isViewLoaded else { return }
                applyDescriptionStyle(to: view)
            }
        }

        private func applyDescriptionStyle(to view: NSView) {
            if let row = view as? ConfigurableView {
                row.inheritedDescriptionStyle = descriptionStyle
            }
            for subview in view.subviews {
                applyDescriptionStyle(to: subview)
            }
        }

        open var contentTopInset: CGFloat = 0 {
            didSet {
                stackTopConstraint?.constant = max(contentTopInset, 0)
            }
        }

        override open func viewDidLoad() {
            super.viewDidLoad()

            view.wantsLayer = true
            view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor

            stackView.orientation = .vertical
            stackView.spacing = 0
            stackView.distribution = .fill
            stackView.translatesAutoresizingMaskIntoConstraints = false

            contentView.translatesAutoresizingMaskIntoConstraints = false

            view.addSubview(contentView)
            contentView.addSubview(stackView)

            let stackTopConstraint = stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: max(contentTopInset, 0))
            self.stackTopConstraint = stackTopConstraint

            NSLayoutConstraint.activate([
                contentView.topAnchor.constraint(equalTo: view.topAnchor),
                contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

                stackTopConstraint,
                stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            ])

            setupContentViews()

            stackView.subviews
                .compactMap { $0 as? any ConfigurableSeparatorProtocol }
                .forEach { separator in
                    separator.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        separator.heightAnchor.constraint(equalToConstant: type(of: separator).defaultHeight),
                        separator.widthAnchor.constraint(equalTo: stackView.widthAnchor),
                    ])
                }
        }

        open func setupContentViews() {}
    }
#endif
