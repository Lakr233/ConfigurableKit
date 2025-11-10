//
//  ConfigToggleCell.swift
//  ConfigurableKit
//
//  Created by GPT-5 Codex on 2025/11/10.
//

import Combine
import UIKit

final class ConfigToggleCell: UITableViewCell {
    static let reuseIdentifier = "ConfigToggleCell"

    private let toggleSwitch = UISwitch(frame: .zero)
    private var cancellable: AnyCancellable?
    private var onToggle: ((Bool) -> Void)?
    private var isUpdatingProgrammatically = false

    override init(style _: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        accessoryView = toggleSwitch
        selectionStyle = .none
        toggleSwitch.addTarget(self, action: #selector(toggleValueChanged(_:)), for: .valueChanged)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cancellable?.cancel()
        cancellable = nil
        onToggle = nil
        toggleSwitch.isEnabled = true
        isUpdatingProgrammatically = false
    }

    func configure(
        descriptor: ConfigToggleElement,
        currentValue: Bool,
        valuePublisher: AnyPublisher<Bool, Never>,
        onToggle: @escaping (Bool) -> Void
    ) {
        var configuration = defaultContentConfiguration()
        configuration.text = descriptor.title ?? descriptor.key.rawValue
        configuration.secondaryText = descriptor.subtitle ?? descriptor.helpText
        configuration.secondaryTextProperties.numberOfLines = 0
        contentConfiguration = configuration

        toggleSwitch.isEnabled = descriptor.isEnabled
        updateSwitch(to: currentValue, animated: false)

        cancellable = valuePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.updateSwitch(to: value, animated: true)
            }

        self.onToggle = onToggle
    }

    func updateSwitch(to value: Bool, animated: Bool) {
        guard toggleSwitch.isOn != value else { return }
        isUpdatingProgrammatically = true
        toggleSwitch.setOn(value, animated: animated)
        isUpdatingProgrammatically = false
    }

    @objc
    private func toggleValueChanged(_ sender: UISwitch) {
        guard !isUpdatingProgrammatically else { return }
        onToggle?(sender.isOn)
    }
}
