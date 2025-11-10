//
//  ConfigPickerCell.swift
//  ConfigurableKit
//
//  Created by GPT-5 Codex on 2025/11/10.
//

import Combine
import UIKit

final class ConfigPickerCell: UITableViewCell {
    static let reuseIdentifier = "ConfigPickerCell"

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        label.numberOfLines = 1
        return label
    }()

    private var cancellable: AnyCancellable?

    override init(style _: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
        selectionStyle = .default
        valueLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        valueLabel.setContentHuggingPriority(.required, for: .horizontal)
        accessoryView = valueLabel
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cancellable?.cancel()
        cancellable = nil
        valueLabel.text = nil
        accessoryView = valueLabel
    }

    func configure(
        descriptor: AnyConfigPickerElement,
        currentValue: String,
        valuePublisher: AnyPublisher<String, Never>
    ) {
        var configuration = defaultContentConfiguration()
        configuration.text = descriptor.title ?? ""
        configuration.secondaryText = descriptor.subtitle
        configuration.secondaryTextProperties.numberOfLines = 0

        if let iconName = descriptor.iconSystemName {
            configuration.image = UIImage(systemName: iconName)
            configuration.imageProperties.tintColor = .secondaryLabel
        }

        contentConfiguration = configuration
        valueLabel.text = currentValue

        cancellable = valuePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.valueLabel.text = value
            }
    }
}
