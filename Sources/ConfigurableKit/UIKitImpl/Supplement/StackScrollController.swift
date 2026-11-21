#if canImport(UIKit)
//
    //  StackScrollController.swift
    //  ConfigurableKit
//
    //  Created by 秋星桥 on 2025/1/4.
//

    import UIKit

    open class StackScrollController: UIViewController {
        public let scrollView = UIScrollView()
        public let contentView = UIView()
        public let stackView = UIStackView()

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

        private func applyDescriptionStyle(to view: UIView) {
            if let row = view as? ConfigurableView {
                row.inheritedDescriptionStyle = descriptionStyle
            }
            for subview in view.subviews {
                applyDescriptionStyle(to: subview)
            }
        }

        override open func viewDidLoad() {
            super.viewDidLoad()

            view.backgroundColor = .systemBackground

            stackView.axis = .vertical
            stackView.spacing = 0
            stackView.distribution = .equalSpacing

            view.addSubview(scrollView)
            scrollView.addSubview(contentView)
            contentView.addSubview(stackView)

            scrollView.clipsToBounds = false
            scrollView.alwaysBounceVertical = true
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            contentView.translatesAutoresizingMaskIntoConstraints = false
            stackView.translatesAutoresizingMaskIntoConstraints = false

            scrollView.contentInset = .init(top: 0, left: 0, bottom: 32, right: 0)

            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: view.topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

                contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor),

                stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
                // A vertically scrolling scroll view only adds the safe area to its
                // vertical content inset, never sideways. Pin the stack to the
                // horizontal safe area so rows stay clear of side insets (landscape
                // notch, iPad sidebar overlay, iPhone Duo side status bar). The
                // scroll view itself still spans the whole view. With no side
                // insets this is the same as pinning to the content view.
                stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
                stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
                stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: 0),
            ])

            setupContentViews()
            stackView
                .subviews
                .compactMap { view -> (any ConfigurableSeparatorProtocol)? in
                    if let separator = view as? any ConfigurableSeparatorProtocol {
                        return separator
                    }
                    return nil
                }.forEach { separator in
                    separator.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        separator.heightAnchor.constraint(equalToConstant: type(of: separator).defaultHeight),
                        separator.widthAnchor.constraint(equalTo: stackView.widthAnchor),
                    ])
                }
        }

        open func setupContentViews() { /* stub */ }
    }
#endif
