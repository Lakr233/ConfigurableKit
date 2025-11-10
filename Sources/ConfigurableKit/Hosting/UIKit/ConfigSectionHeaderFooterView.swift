//
//  ConfigSectionHeaderFooterView.swift
//  ConfigurableKit
//
//  Created by GPT-5 Codex on 2025/11/10.
//

import UIKit

final class ConfigSectionHeaderView: UITableViewHeaderFooterView {
    static let reuseIdentifier = "ConfigSectionHeaderView"

    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let stackView = UIStackView()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.layoutMargins = UIEdgeInsets(top: 8, left: 20, bottom: 4, right: 20)

        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .secondaryLabel
        iconView.setContentHuggingPriority(.required, for: .horizontal)
        iconView.setContentCompressionResistancePriority(.required, for: .horizontal)

        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .label

        subtitleLabel.font = .preferredFont(forTextStyle: .footnote)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0

        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)

        let container = UIStackView(arrangedSubviews: [iconView, stackView])
        container.axis = .horizontal
        container.spacing = 12
        container.alignment = .center

        iconView.isHidden = true
        subtitleLabel.isHidden = true

        contentView.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            container.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
        ])
    }

    func configure(with header: ConfigSectionHeader?) {
        iconView.isHidden = header?.iconSystemName == nil
        if let systemName = header?.iconSystemName {
            iconView.image = UIImage(systemName: systemName)
        }

        titleLabel.text = header?.title
        subtitleLabel.text = header?.subtitle
        subtitleLabel.isHidden = (header?.subtitle?.isEmpty ?? true)
    }
}

final class ConfigSectionFooterView: UITableViewHeaderFooterView {
    static let reuseIdentifier = "ConfigSectionFooterView"

    private let iconView = UIImageView()
    private let textLabelView = UILabel()
    private let container = UIStackView()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.layoutMargins = UIEdgeInsets(top: 4, left: 20, bottom: 12, right: 20)

        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .secondaryLabel
        iconView.setContentHuggingPriority(.required, for: .horizontal)
        iconView.setContentCompressionResistancePriority(.required, for: .horizontal)

        textLabelView.font = .preferredFont(forTextStyle: .footnote)
        textLabelView.textColor = .secondaryLabel
        textLabelView.numberOfLines = 0

        container.axis = .horizontal
        container.spacing = 12
        container.alignment = .top
        container.addArrangedSubview(iconView)
        container.addArrangedSubview(textLabelView)

        iconView.isHidden = true

        contentView.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            container.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
        ])
    }

    func configure(with footer: ConfigSectionFooter?) {
        textLabelView.text = footer?.text
        iconView.isHidden = footer?.iconSystemName == nil
        if let systemName = footer?.iconSystemName {
            iconView.image = UIImage(systemName: systemName)
        }
    }
}
