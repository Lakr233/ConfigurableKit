//
//  ConfigurableView.swift
//  TRApp
//
//  Created by 秋星桥 on 2024/2/13.
//

import Combine
import Foundation
#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#endif

let elementSpacing: CGFloat = 10

#if canImport(UIKit)
    open class ConfigurableView: UIStackView {
        open lazy var headerStackView = UIStackView()

        open lazy var iconContainer = UIView()
        open lazy var iconView = UIImageView()
        open lazy var titleLabel = UILabel()

        open lazy var verticalStack = UIStackView()
        open lazy var descriptionLabel = UILabel()
        open lazy var contentContainer = EasyHitView()

        open lazy var contentView = Self.createContentView()

        open var cancellables = Set<AnyCancellable>()

        /// How this row shows its explanation. `nil` (the default) follows the
        /// `descriptionStyle` of the `StackScrollController` showing the row,
        /// and shows the full explanation when that is not set either.
        open var descriptionStyle: ConfigurableDescriptionStyle? {
            didSet { applyDescriptionStyle() }
        }

        /// The style the row is showing its explanation with, after following the page.
        public var effectiveDescriptionStyle: ConfigurableDescriptionStyle {
            descriptionStyle ?? inheritedDescriptionStyle ?? .full
        }

        /// Where the row puts its value. `.automatic` (the default) keeps it
        /// beside the title while it fits and moves it under the title otherwise.
        open var valuePlacement: ConfigurableValuePlacement = .automatic {
            didSet {
                guard oldValue != valuePlacement else { return }
                setNeedsLayout()
            }
        }

        /// Whether the value is currently on its own line under the title.
        public private(set) var isValueBelowTitle = false

        var inheritedDescriptionStyle: ConfigurableDescriptionStyle? {
            didSet {
                guard oldValue != inheritedDescriptionStyle else { return }
                applyDescriptionStyle()
            }
        }

        private var appliedDescriptionStyle: ConfigurableDescriptionStyle?
        private var originalDescriptionLines: (count: Int, lineBreakMode: NSLineBreakMode)?
        private var originalValueAppearance: ValueAppearance?
        private lazy var trailingValueConstraints: [NSLayoutConstraint] = [
            contentContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ]
        private lazy var belowTitleValueConstraints: [NSLayoutConstraint] = {
            let hugging = contentContainer.widthAnchor.constraint(equalTo: contentView.widthAnchor)
            hugging.priority = .defaultLow
            return [
                contentContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                contentContainer.trailingAnchor.constraint(greaterThanOrEqualTo: contentView.trailingAnchor),
                contentContainer.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor),
                hugging,
                verticalStack.widthAnchor.constraint(equalTo: widthAnchor),
                descriptionLabel.widthAnchor.constraint(equalTo: widthAnchor),
            ]
        }()

        private lazy var wrappedValueHeightConstraint: NSLayoutConstraint = {
            let constraint = contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
            constraint.priority = .required - 1
            return constraint
        }()

        private struct ValueAppearance {
            var numberOfLines: Int
            var lineBreakMode: NSLineBreakMode
            var textAlignment: NSTextAlignment
            var contentHorizontalAlignment: UIControl.ContentHorizontalAlignment?
        }

        public init() {
            super.init(frame: .zero)
            commitInit()
        }

        @available(*, unavailable)
        public required init(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        open func commitInit() {
            translatesAutoresizingMaskIntoConstraints = false
            iconContainer.translatesAutoresizingMaskIntoConstraints = false
            iconView.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
            contentView.translatesAutoresizingMaskIntoConstraints = false
            verticalStack.translatesAutoresizingMaskIntoConstraints = false
            headerStackView.translatesAutoresizingMaskIntoConstraints = false
            contentContainer.translatesAutoresizingMaskIntoConstraints = false

            axis = .horizontal
            spacing = elementSpacing
            distribution = .fill
            alignment = .center
            addArrangedSubviews([verticalStack, contentContainer])

            contentContainer.addSubview(contentView)
            NSLayoutConstraint.activate([
                contentContainer.widthAnchor.constraint(greaterThanOrEqualToConstant: 64),
                contentContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 32),
                contentContainer.leadingAnchor.constraint(lessThanOrEqualTo: contentView.leadingAnchor),
                contentContainer.topAnchor.constraint(lessThanOrEqualTo: contentView.topAnchor),
                contentContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            ])
            NSLayoutConstraint.activate(trailingValueConstraints)

            headerStackView.axis = .horizontal
            headerStackView.spacing = elementSpacing

            iconContainer.addSubview(iconView)
            headerStackView.addArrangedSubview(iconContainer)
            headerStackView.addArrangedSubview(titleLabel)
            headerStackView.addArrangedSubview(UIView())

            iconView.tintColor = .label
            iconView.image = UIImage(systemName: "questionmark.circle", withConfiguration: .icon)
            iconView.contentMode = .scaleAspectFit
            iconView.translatesAutoresizingMaskIntoConstraints = false

            iconView.setContentHuggingPriority(.defaultHigh, for: .vertical)
            iconView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

            NSLayoutConstraint.activate([
                iconView.topAnchor.constraint(equalTo: iconContainer.topAnchor),
                iconView.bottomAnchor.constraint(equalTo: iconContainer.bottomAnchor),
                iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
                iconContainer.widthAnchor.constraint(equalTo: iconContainer.heightAnchor, multiplier: 1),
            ])

            titleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline).semibold
            titleLabel.adjustsFontForContentSizeCategory = true
            titleLabel.numberOfLines = 1
            titleLabel.lineBreakMode = .byTruncatingTail

            NSLayoutConstraint.activate([
                iconContainer.heightAnchor.constraint(equalTo: titleLabel.heightAnchor),
            ])

            descriptionLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
            descriptionLabel.adjustsFontForContentSizeCategory = true
            descriptionLabel.textColor = .secondaryLabel
            descriptionLabel.numberOfLines = 0
            descriptionLabel.lineBreakMode = .byWordWrapping
            descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
            addSubview(descriptionLabel)

            verticalStack.axis = .vertical
            verticalStack.spacing = elementSpacing
            verticalStack.alignment = .leading
            verticalStack.distribution = .fill
            verticalStack.addArrangedSubview(headerStackView)
            verticalStack.addArrangedSubview(descriptionLabel)
        }

        deinit {
            MainActor.assumeIsolated {
                cancellables.forEach { $0.cancel() }
                cancellables.removeAll()
            }
        }

        open class func createContentView() -> UIView {
            .init()
        }

        open func configure(icon: CKImage?) {
            iconView.image = icon?.applyingSymbolConfiguration(.icon)
        }

        open func configure(title: String.LocalizationValue) {
            titleLabel.text = String(localized: title)
        }

        open func configure(description: String.LocalizationValue) {
            titleLabel.accessibilityHint = String(localized: description)
            descriptionLabel.text = String(localized: description)
            descriptionLabel.isHidden = String(localized: description).isEmpty
                || effectiveDescriptionStyle == .hidden
            setNeedsLayout()
        }

        @_disfavoredOverload
        open func configure(title: String) {
            configure(title: String.LocalizationValue(title))
        }

        @_disfavoredOverload
        open func configure(description: String) {
            configure(description: String.LocalizationValue(description))
        }

        open func subscribeToAvailability(_ publisher: AnyPublisher<Bool, Never>, initialValue: Bool) {
            publisher
                .ensureMainThread()
                .sink { [weak self] isEnabled in
                    self?.update(availability: isEnabled)
                }
                .store(in: &cancellables)
            update(availability: initialValue)
        }

        // MARK: - Description Style

        override open func didMoveToWindow() {
            super.didMoveToWindow()
            guard window != nil else { return }
            inheritedDescriptionStyle = hostingStackScrollController?.descriptionStyle
        }

        private var hostingStackScrollController: StackScrollController? {
            var responder: UIResponder? = next
            while let current = responder {
                if let controller = current as? StackScrollController {
                    return controller
                }
                responder = current.next
            }
            return nil
        }

        private func applyDescriptionStyle() {
            let style = effectiveDescriptionStyle
            guard style != appliedDescriptionStyle else { return }
            let previous = appliedDescriptionStyle
            appliedDescriptionStyle = style

            if originalDescriptionLines == nil, style != .full {
                originalDescriptionLines = (descriptionLabel.numberOfLines, descriptionLabel.lineBreakMode)
            }
            switch style {
            case .singleLine:
                descriptionLabel.numberOfLines = 1
                descriptionLabel.lineBreakMode = .byTruncatingTail
            case .full, .hidden:
                if let originalDescriptionLines {
                    descriptionLabel.numberOfLines = originalDescriptionLines.count
                    descriptionLabel.lineBreakMode = originalDescriptionLines.lineBreakMode
                }
            }
            if style == .hidden {
                descriptionLabel.isHidden = true
            } else if previous == .hidden {
                descriptionLabel.isHidden = descriptionLabel.text?.isEmpty ?? true
            }
            setNeedsLayout()
        }

        private var isDescriptionVisible: Bool {
            !descriptionLabel.isHidden && !(descriptionLabel.text?.isEmpty ?? true)
        }

        // MARK: - Value Placement

        /// The width the value needs to show completely on one line.
        ///
        /// The default measures the content view: a button or label by its text,
        /// anything else by its intrinsic content size. Override it when the
        /// content view does not report its own width.
        open func naturalValueWidth() -> CGFloat {
            if let label = contentView as? UILabel {
                let size = label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: .greatestFiniteMagnitude))
                return ceil(size.width)
            }
            let width = contentView.intrinsicContentSize.width
            return width == UIView.noIntrinsicMetric ? 0 : ceil(width)
        }

        /// Called after the value moved under the title or back beside it
        /// (see `isValueBelowTitle`).
        ///
        /// The default lets a button or label wrap, aligned to the leading edge,
        /// while it is under the title, and puts back its own line settings when
        /// it returns beside the title. Override it to adjust a custom value view.
        open func valuePlacementDidChange() {
            if isValueBelowTitle {
                let label: UILabel?
                let button = contentView as? UIButton
                if let button {
                    label = button.titleLabel
                } else {
                    label = contentView as? UILabel
                }
                guard let label else { return }
                if originalValueAppearance == nil {
                    originalValueAppearance = .init(
                        numberOfLines: label.numberOfLines,
                        lineBreakMode: label.lineBreakMode,
                        textAlignment: label.textAlignment,
                        contentHorizontalAlignment: button?.contentHorizontalAlignment
                    )
                }
                label.numberOfLines = 0
                label.lineBreakMode = .byWordWrapping
                label.textAlignment = .natural
                button?.contentHorizontalAlignment = .leading
            } else if let original = originalValueAppearance {
                originalValueAppearance = nil
                let button = contentView as? UIButton
                guard let label = button?.titleLabel ?? contentView as? UILabel else { return }
                label.numberOfLines = original.numberOfLines
                label.lineBreakMode = original.lineBreakMode
                label.textAlignment = original.textAlignment
                if let alignment = original.contentHorizontalAlignment {
                    button?.contentHorizontalAlignment = alignment
                }
            }
        }

        /// The row keeps its value beside the title when a subclass changed the
        /// arrangement this layout relies on (for example removed the value).
        private var supportsValueBelowTitle: Bool {
            let arranged = arrangedSubviews
            guard arranged.count == 2 || (arranged.count == 3 && isValueBelowTitle) else { return false }
            guard arranged[0] === verticalStack, arranged[1] === contentContainer else { return false }
            if isValueBelowTitle {
                return arranged.count == 3 && arranged[2] === descriptionLabel
                    && verticalStack.arrangedSubviews == [headerStackView]
            }
            return verticalStack.arrangedSubviews == [headerStackView, descriptionLabel]
        }

        /// The width the header (icon, title and the trailing spacer view) needs
        /// to show the title in full, including the spacing between them.
        private var titleNaturalWidth: CGFloat {
            let visible = headerStackView.arrangedSubviews.filter { !$0.isHidden }
            var width: CGFloat = 0
            for view in visible {
                if view === titleLabel {
                    width += ceil(titleLabel.intrinsicContentSize.width)
                } else if view === iconContainer {
                    // The icon is square and as tall as the title.
                    width += ceil(titleLabel.intrinsicContentSize.height)
                } else {
                    width += max(0, ceil(view.intrinsicContentSize.width))
                }
            }
            width += headerStackView.spacing * CGFloat(max(visible.count - 1, 0))
            return width
        }

        private func resolveValuePlacement(forWidth rowWidth: CGFloat) {
            guard rowWidth > 0, rowWidth.isFinite, supportsValueBelowTitle else { return }
            let below: Bool
            switch valuePlacement {
            case .trailing:
                below = false
            case .belowTitle:
                below = true
            case .automatic:
                below = ConfigurableRowLayout.prefersValueBelowTitle(
                    rowWidth: rowWidth,
                    valueWidth: naturalValueWidth(),
                    titleWidth: titleNaturalWidth,
                    isDescriptionVisible: isDescriptionVisible,
                    spacing: spacing
                )
            }
            setValueBelowTitle(below)
        }

        private func setValueBelowTitle(_ below: Bool) {
            guard below != isValueBelowTitle else { return }
            guard supportsValueBelowTitle else { return }
            isValueBelowTitle = below

            if below {
                NSLayoutConstraint.deactivate(trailingValueConstraints)
                verticalStack.removeArrangedSubview(descriptionLabel)
                addArrangedSubview(descriptionLabel)
                axis = .vertical
                alignment = .leading
                setCustomSpacing(2, after: verticalStack)
                setCustomSpacing(2, after: contentContainer)
                NSLayoutConstraint.activate(belowTitleValueConstraints)
                NSLayoutConstraint.activate([wrappedValueHeightConstraint])
            } else {
                NSLayoutConstraint.deactivate(belowTitleValueConstraints)
                NSLayoutConstraint.deactivate([wrappedValueHeightConstraint])
                wrappedValueHeightConstraint.constant = 0
                removeArrangedSubview(descriptionLabel)
                verticalStack.addArrangedSubview(descriptionLabel)
                setCustomSpacing(UIStackView.spacingUseDefault, after: verticalStack)
                setCustomSpacing(UIStackView.spacingUseDefault, after: contentContainer)
                axis = .horizontal
                alignment = .center
                NSLayoutConstraint.activate(trailingValueConstraints)
            }
            valuePlacementDidChange()
            invalidateIntrinsicContentSize()
            superview?.setNeedsLayout()
        }

        /// A button keeps a one-line height even when its title wraps, so give
        /// it the height its wrapped title needs while it is under the title.
        private func updateWrappedValueHeight() {
            guard isValueBelowTitle else { return }
            var height: CGFloat = 0
            if let button = contentView as? UIButton, let label = button.titleLabel,
               label.numberOfLines != 1, contentView.bounds.width > 0
            {
                let size = label.sizeThatFits(CGSize(width: contentView.bounds.width, height: .greatestFiniteMagnitude))
                height = ceil(size.height)
            }
            if abs(wrappedValueHeightConstraint.constant - height) > 0.5 {
                wrappedValueHeightConstraint.constant = height
            }
        }

        override open func layoutSubviews() {
            resolveValuePlacement(forWidth: bounds.width)
            super.layoutSubviews()
            updateWrappedValueHeight()
        }

        override open func systemLayoutSizeFitting(
            _ targetSize: CGSize,
            withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
            verticalFittingPriority: UILayoutPriority
        ) -> CGSize {
            if horizontalFittingPriority >= .defaultHigh {
                resolveValuePlacement(forWidth: targetSize.width)
            }
            return super.systemLayoutSizeFitting(
                targetSize,
                withHorizontalFittingPriority: horizontalFittingPriority,
                verticalFittingPriority: verticalFittingPriority
            )
        }

        override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            super.traitCollectionDidChange(previousTraitCollection)
            if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
                setNeedsLayout()
            }
        }

        private func update(availability: Bool) {
            isUserInteractionEnabled = availability
            UIView.animate(withDuration: 0.25) {
                self.alpha = availability ? 1 : 0.25
            }
        }
    }

#elseif canImport(AppKit)
    open class ConfigurableView: NSStackView {
        private var isAvailable = true

        open lazy var headerStackView = NSStackView()

        open lazy var iconContainer = NSView()
        open lazy var iconView = NSImageView()
        open lazy var titleLabel = NSTextField(labelWithString: "")

        open lazy var verticalStack = NSStackView()
        open lazy var descriptionLabel = NSTextField(labelWithString: "")
        open lazy var contentContainer = EasyHitView()

        open lazy var contentView = Self.createContentView()

        open var cancellables = Set<AnyCancellable>()

        /// How this row shows its explanation. `nil` (the default) follows the
        /// `descriptionStyle` of the `StackScrollController` showing the row,
        /// and shows the full explanation when that is not set either.
        open var descriptionStyle: ConfigurableDescriptionStyle? {
            didSet { applyDescriptionStyle() }
        }

        /// The style the row is showing its explanation with, after following the page.
        public var effectiveDescriptionStyle: ConfigurableDescriptionStyle {
            descriptionStyle ?? inheritedDescriptionStyle ?? .full
        }

        var inheritedDescriptionStyle: ConfigurableDescriptionStyle? {
            didSet {
                guard oldValue != inheritedDescriptionStyle else { return }
                applyDescriptionStyle()
            }
        }

        private var appliedDescriptionStyle: ConfigurableDescriptionStyle?
        private var originalDescriptionLines: (count: Int, lineBreakMode: NSLineBreakMode)?

        override public init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            commitInit()
        }

        public convenience init() {
            self.init(frame: .zero)
        }

        @available(*, unavailable)
        public required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        open func commitInit() {
            translatesAutoresizingMaskIntoConstraints = false
            iconContainer.translatesAutoresizingMaskIntoConstraints = false
            iconView.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
            contentView.translatesAutoresizingMaskIntoConstraints = false
            verticalStack.translatesAutoresizingMaskIntoConstraints = false
            headerStackView.translatesAutoresizingMaskIntoConstraints = false
            contentContainer.translatesAutoresizingMaskIntoConstraints = false

            orientation = .horizontal
            spacing = elementSpacing
            distribution = .fill
            alignment = .centerY
            addArrangedSubview(verticalStack)
            addArrangedSubview(contentContainer)

            contentContainer.addSubview(contentView)
            NSLayoutConstraint.activate([
                contentContainer.widthAnchor.constraint(greaterThanOrEqualToConstant: 64),
                contentContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 32),
                contentContainer.leadingAnchor.constraint(lessThanOrEqualTo: contentView.leadingAnchor),
                contentContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                contentContainer.topAnchor.constraint(lessThanOrEqualTo: contentView.topAnchor),
                contentContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            ])

            headerStackView.orientation = .horizontal
            headerStackView.spacing = elementSpacing

            iconContainer.addSubview(iconView)
            headerStackView.addArrangedSubview(iconContainer)
            headerStackView.addArrangedSubview(titleLabel)
            headerStackView.addArrangedSubview(NSView())

            iconView.contentTintColor = .labelColor
            iconView.image = NSImage(systemSymbolName: "questionmark.circle", accessibilityDescription: nil)
            iconView.imageScaling = .scaleProportionallyUpOrDown

            NSLayoutConstraint.activate([
                iconView.topAnchor.constraint(equalTo: iconContainer.topAnchor),
                iconView.bottomAnchor.constraint(equalTo: iconContainer.bottomAnchor),
                iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
                iconContainer.widthAnchor.constraint(equalTo: iconContainer.heightAnchor, multiplier: 1),
            ])

            titleLabel.font = .systemFont(ofSize: NSFont.preferredFont(forTextStyle: .subheadline).pointSize, weight: .semibold)
            titleLabel.lineBreakMode = .byTruncatingTail
            titleLabel.maximumNumberOfLines = 1

            NSLayoutConstraint.activate([
                iconContainer.heightAnchor.constraint(equalTo: titleLabel.heightAnchor),
            ])

            descriptionLabel.font = NSFont.preferredFont(forTextStyle: .footnote)
            descriptionLabel.textColor = .secondaryLabelColor
            descriptionLabel.maximumNumberOfLines = 0
            descriptionLabel.lineBreakMode = .byWordWrapping

            verticalStack.orientation = .vertical
            verticalStack.spacing = elementSpacing
            verticalStack.alignment = .leading
            verticalStack.distribution = .fill
            verticalStack.addArrangedSubview(headerStackView)
            verticalStack.addArrangedSubview(descriptionLabel)
        }

        deinit {
            MainActor.assumeIsolated {
                cancellables.forEach { $0.cancel() }
                cancellables.removeAll()
            }
        }

        open class func createContentView() -> NSView {
            .init()
        }

        open func configure(icon: CKImage?) {
            iconView.image = icon
        }

        open func configure(title: String.LocalizationValue) {
            titleLabel.stringValue = String(localized: title)
        }

        open func configure(description: String.LocalizationValue) {
            descriptionLabel.stringValue = String(localized: description)
            descriptionLabel.isHidden = descriptionLabel.stringValue.isEmpty
                || effectiveDescriptionStyle == .hidden
        }

        override open func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            guard window != nil else { return }
            var responder: NSResponder? = nextResponder
            while let current = responder {
                if let controller = current as? StackScrollController {
                    inheritedDescriptionStyle = controller.descriptionStyle
                    return
                }
                responder = current.nextResponder
            }
        }

        private func applyDescriptionStyle() {
            let style = effectiveDescriptionStyle
            guard style != appliedDescriptionStyle else { return }
            let previous = appliedDescriptionStyle
            appliedDescriptionStyle = style

            if originalDescriptionLines == nil, style != .full {
                originalDescriptionLines = (descriptionLabel.maximumNumberOfLines, descriptionLabel.lineBreakMode)
            }
            switch style {
            case .singleLine:
                descriptionLabel.maximumNumberOfLines = 1
                descriptionLabel.lineBreakMode = .byTruncatingTail
            case .full, .hidden:
                if let originalDescriptionLines {
                    descriptionLabel.maximumNumberOfLines = originalDescriptionLines.count
                    descriptionLabel.lineBreakMode = originalDescriptionLines.lineBreakMode
                }
            }
            if style == .hidden {
                descriptionLabel.isHidden = true
            } else if previous == .hidden {
                descriptionLabel.isHidden = descriptionLabel.stringValue.isEmpty
            }
        }

        @_disfavoredOverload
        open func configure(title: String) {
            configure(title: String.LocalizationValue(title))
        }

        @_disfavoredOverload
        open func configure(description: String) {
            configure(description: String.LocalizationValue(description))
        }

        open func subscribeToAvailability(_ publisher: AnyPublisher<Bool, Never>, initialValue: Bool) {
            publisher
                .ensureMainThread()
                .sink { [weak self] isEnabled in
                    self?.update(availability: isEnabled)
                }
                .store(in: &cancellables)
            update(availability: initialValue)
        }

        private func update(availability: Bool) {
            isAvailable = availability
            alphaValue = availability ? 1 : 0.25
        }

        override open func hitTest(_ point: NSPoint) -> NSView? {
            guard isAvailable else { return nil }
            return super.hitTest(point)
        }
    }
#endif

extension Publisher {
    func ensureMainThread() -> AnyPublisher<Output, Failure> {
        flatMap { value -> AnyPublisher<Output, Failure> in
            if Thread.isMainThread {
                return Just(value)
                    .setFailureType(to: Failure.self)
                    .eraseToAnyPublisher()
            } else {
                return Just(value)
                    .delay(for: .zero, scheduler: DispatchQueue.main)
                    .setFailureType(to: Failure.self)
                    .eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }
}
