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
                contentContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                contentContainer.topAnchor.constraint(lessThanOrEqualTo: contentView.topAnchor),
                contentContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            ])

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
