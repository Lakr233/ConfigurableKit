//
//  ConfigurableView.swift
//  TRApp
//
//  Created by 秋星桥 on 2024/2/13.
//

import Combine
import ConfigurableKitAnyCodable
import UIKit

let elementSpacing: CGFloat = 10

open class ConfigurableView: UIStackView {
    lazy var headerStackView = UIStackView()

    lazy var iconContainer = UIView()
    lazy var iconView = UIImageView()
    lazy var titleLabel = UILabel()

    lazy var verticalStack = UIStackView()
    lazy var descriptionLabel = UILabel()
    lazy var contentContainer = EasyHitView()

    public lazy var contentView = Self.createContentView()

    public var cancellables = Set<AnyCancellable>()

    public init() {
        super.init(frame: .zero)
        commitInit()
    }

    @available(*, unavailable)
    public required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func commitInit() {
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
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }

    open class func createContentView() -> UIView {
        .init()
    }

    func configure(icon: UIImage?) {
        iconView.image = icon?.applyingSymbolConfiguration(.icon)
    }

    func configure(title: String) {
        titleLabel.text = title
    }

    func configure(description: String) {
        titleLabel.accessibilityHint = description
        descriptionLabel.text = description
    }

    func subscribeToAvailability(_ publisher: AnyPublisher<Bool, Never>, initialValue: Bool) {
        publisher
            .receive(on: DispatchQueue.main)
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