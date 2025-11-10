//
//  ConfigHostingController.swift
//  ConfigurableKit
//
//  Created by GPT-5 Codex on 2025/11/10.
//

import Combine
import UIKit

@MainActor
public final class ConfigHostingController<Page: ConfigPage>: StackScrollController {
    private let page: Page
    private var sections: [ConfigSectionNode] = []
    private var cancellables: Set<AnyCancellable> = []
    private var actionTasks: [AnyHashable: Task<Void, Never>] = [:]

    public init(_ page: Page) {
        self.page = page
        super.init(nibName: nil, bundle: nil)
        title = "Settings"
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        reloadSections()
    }

    public func reloadSections() {
        sections = page.makeSections()
            .filter(\.isVisible)
            .map { section in
                var filtered = section
                filtered.elements = section.elements.filter(\.isVisible)
                return filtered
            }
            .filter { !$0.elements.isEmpty || $0.header != nil || $0.footer != nil }
        rebuildStack()
    }

    private func rebuildStack() {
        cancellables.removeAll()
        actionTasks.values.forEach { $0.cancel() }
        actionTasks.removeAll()

        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        guard !sections.isEmpty else { return }

        stackView.addArrangedSubview(SeparatorView())
        let lastIndex = sections.indices.last ?? 0
        for (index, section) in sections.enumerated() {
            addSection(section, isLast: index == lastIndex)
        }
    }

    private func addSection(_ section: ConfigSectionNode, isLast: Bool) {
        if let header = section.header, let title = header.title, !title.isEmpty {
            let headerView = ConfigurableSectionHeaderView().with(rawHeader: title)
            stackView.addArrangedSubviewWithMargin(headerView) { margin in
                margin.bottom /= 2
            }
            if let subtitle = header.subtitle, !subtitle.isEmpty {
                let subtitleView = ConfigurableLabelView()
                subtitleView.configure(icon: .image(optionalName: header.iconSystemName ?? ""))
                subtitleView.configure(title: String.LocalizationValue(stringLiteral: subtitle))
                subtitleView.configure(description: "")
                stackView.addArrangedSubviewWithMargin(subtitleView) { margin in
                    margin.top = 0
                    margin.bottom /= 2
                }
            }
        }

        for element in section.elements {
            guard let view = makeView(for: element) else { continue }
            stackView.addArrangedSubviewWithMargin(view)
            stackView.addArrangedSubview(SeparatorView())
        }

        if let footer = section.footer {
            let footerView = ConfigurableSectionFooterView().with(rawFooter: footer.text)
            stackView.addArrangedSubviewWithMargin(footerView) { margin in
                margin.top /= 2
            }
        }

        if !isLast {
            stackView.addArrangedSubview(SeparatorView())
        }
    }

    private func makeView(for element: ConfigElementNode) -> ConfigurableView? {
        switch element.kind {
        case let .toggle(descriptor):
            return makeToggleView(for: descriptor)
        case let .action(descriptor):
            return makeActionView(for: descriptor)
        case let .info(descriptor):
            return makeInfoView(for: descriptor)
        case let .picker(descriptor):
            return makePickerView(for: descriptor)
        }
    }

    private func makeToggleView(for descriptor: ConfigToggleElement) -> ConfigurableView? {
        let storage = makeCodableStorage(for: descriptor.key)
        let toggleView = ConfigurableBooleanView(storage: storage)
        configure(toggleView,
                  iconSystemName: descriptor.iconSystemName,
                  title: descriptor.title,
                  subtitle: descriptor.subtitle,
                  helpText: descriptor.helpText)
        toggleView.switchView.isEnabled = descriptor.isEnabled
        toggleView.alpha = descriptor.isEnabled ? 1 : 0.4

        if let handler = descriptor.handler {
            ConfigurableKit.publisher(for: descriptor.key)
                .dropFirst()
                .sink { value in
                    Task { await handler(value) }
                }
                .store(in: &cancellables)
        }

        return toggleView
    }

    private func makeActionView(for descriptor: ConfigActionElement) -> ConfigurableView? {
        let actionView = ConfigurableActionView()
        actionView.actionBlock = { [weak self, weak actionView] _ in
            guard let handler = descriptor.handler, descriptor.isEnabled else { return }
            guard self?.actionTasks[descriptor.id] == nil else { return }

            let task = Task { @MainActor in
                actionView?.isUserInteractionEnabled = false
                actionView?.alpha = 0.4
                defer {
                    actionView?.isUserInteractionEnabled = descriptor.isEnabled
                    actionView?.alpha = descriptor.isEnabled ? 1 : 0.4
                    self?.actionTasks[descriptor.id] = nil
                }
                await handler()
            }
            self?.actionTasks[descriptor.id] = task
        }

        configure(actionView,
                  iconSystemName: descriptor.iconSystemName,
                  title: descriptor.title,
                  subtitle: descriptor.subtitle,
                  helpText: nil)

        switch descriptor.role {
        case .normal:
            actionView.titleLabel.textColor = UIColor.label
        case .primary:
            actionView.titleLabel.textColor = UIColor.accent
        case .destructive:
            actionView.titleLabel.textColor = UIColor.systemRed
        }

        actionView.isUserInteractionEnabled = descriptor.isEnabled
        actionView.alpha = descriptor.isEnabled ? 1 : 0.4
        return actionView
    }

    private func makeInfoView(for descriptor: ConfigInfoElement) -> ConfigurableView? {
        switch descriptor.style {
        case .footer:
            let footerView = ConfigurableSectionFooterView().with(rawFooter: descriptor.text)
            return footerView
        case .inline:
            let labelView = ConfigurableLabelView()
            configure(labelView,
                      iconSystemName: descriptor.iconSystemName,
                      title: descriptor.text,
                      subtitle: nil,
                      helpText: nil)
            return labelView
        }
    }

    private func makePickerView(for descriptor: AnyConfigPickerElement) -> ConfigurableView? {
        let pickerView = ConfigurableActionView()
        pickerView.actionBlock = { [weak self, weak pickerView] _ in
            self?.presentPickerOptions(descriptor, anchor: pickerView)
        }
        configure(pickerView,
                  iconSystemName: descriptor.iconSystemName,
                  title: descriptor.title,
                  subtitle: descriptor.subtitle,
                  helpText: nil)
        updatePickerDescription(pickerView, subtitle: descriptor.subtitle, displayValue: descriptor.displayValue())

        descriptor.valuePublisher
            .sink { [weak self, weak pickerView, subtitle = descriptor.subtitle] value in
                guard let pickerView else { return }
                self?.updatePickerDescription(pickerView, subtitle: subtitle, displayValue: value)
            }
            .store(in: &cancellables)

        return pickerView
    }

    private func configure(
        _ view: ConfigurableView,
        iconSystemName: String?,
        title: String?,
        subtitle: String?,
        helpText: String?
    ) {
        if let iconSystemName, !iconSystemName.isEmpty {
            view.configure(icon: .image(optionalName: iconSystemName))
        } else {
            view.configure(icon: nil)
        }

        view.configure(title: String.LocalizationValue(stringLiteral: title ?? ""))

        let descriptions = [subtitle, helpText]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: "\n\n")
        view.configure(description: String.LocalizationValue(stringLiteral: descriptions))
    }

    private func updatePickerDescription(_ view: ConfigurableView, subtitle: String?, displayValue: String) {
        let combined = [subtitle, displayValue]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: "\n\n")
        view.configure(description: String.LocalizationValue(stringLiteral: combined))
    }

    private func makeCodableStorage<Value>(for key: ConfigKey<Value>) -> CodableStorage {
        let store = key.resolvedStore(default: ConfigurableKit.configStore)
        let keyValueStorage: KeyValueStorage
        if let keyValueStore = store as? KeyValueConfigStore {
            keyValueStorage = keyValueStore.storage
        } else if let keyValueStore = ConfigurableKit.configStore as? KeyValueConfigStore {
            keyValueStorage = keyValueStore.storage
        } else {
            keyValueStorage = ConfigurableKit.storage
        }
        return CodableStorage(
            key: key.rawValue,
            defaultValue: ConfigurableKitAnyCodable(key.defaultValue),
            storage: keyValueStorage
        )
    }

    private func presentPickerOptions(_ descriptor: AnyConfigPickerElement, anchor: UIView?) {
        let alert = UIAlertController(
            title: descriptor.title,
            message: descriptor.subtitle,
            preferredStyle: .actionSheet
        )

        for option in descriptor.options {
            let prefix = option.isSelected() ? "✓ " : ""
            let title = prefix + option.title
            let action = UIAlertAction(title: title, style: .default) { _ in
                option.select()
            }
            alert.addAction(action)
        }

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))

        if let popover = alert.popoverPresentationController, let anchor {
            popover.sourceView = anchor
            popover.sourceRect = anchor.bounds
        }

        present(alert, animated: true)
    }
}
