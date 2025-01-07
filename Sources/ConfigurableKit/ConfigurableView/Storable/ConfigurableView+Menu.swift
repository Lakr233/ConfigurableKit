//
//  ConfigurableView+Menu.swift
//  TRApp
//
//  Created by 82Flex on 2024/9/14.
//

import Combine
import OrderedCollections
import UIKit

class ConfigurableMenuView: ConfigurableValueView {
    var button: EasyHitButton { contentView as! EasyHitButton }
    let selection: [ListAnnotation.ValueItem]

    init(storage: CodableStorage, selection: [ListAnnotation.ValueItem]) {
        self.selection = selection
        super.init(storage: storage)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.contentHorizontalAlignment = .trailing

        if !selection.isEmpty {
            button.showsMenuAsPrimaryAction = true
            button.menu = buildMenuWithSelection(selection)
        }
    }

    override class func createContentView() -> UIView {
        EasyHitButton()
    }

    override func updateValue() {
        super.updateValue()
        let value = value
        UIView.transition(
            with: self,
            duration: 0.25,
            options: [.transitionCrossDissolve]
        ) {
            [weak self] in
            self?.executeUpdateValue(value)
        }
    }

    func executeUpdateValue(_ value: ConfigurableKitAnyCodable) {
        var text: String = value.decodingValue(defaultValue: String(describing: value))
        for item in selection where item.rawValue == value {
            text = item.title
            break
        }

        if text.isEmpty { text = NSLocalizedString("Unspecified", comment: "") }

        let attrString = NSAttributedString(string: text, attributes: [
            .foregroundColor: UIColor.accent,
            .font: UIFont.preferredFont(forTextStyle: .subheadline).semibold,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
        ])

        let pressedAttrString = NSAttributedString(string: text, attributes: [
            .foregroundColor: UIColor.accent.withAlphaComponent(0.5),
            .font: UIFont.preferredFont(forTextStyle: .subheadline).semibold,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
        ])

        button.setAttributedTitle(attrString, for: .normal)
        button.setAttributedTitle(pressedAttrString, for: .highlighted)
        button.setAttributedTitle(pressedAttrString, for: .disabled)
        button.setAttributedTitle(pressedAttrString, for: .selected)
    }
}

extension ConfigurableMenuView {
    func buildMenuWithSelection(_ selection: [ListAnnotation.ValueItem]) -> UIMenu {
        let groupedselection: OrderedDictionary<String, [ListAnnotation.ValueItem]>
        groupedselection = selection.reduce(into: [:]) { result, item in
            result[item.section, default: []].append(item)
        }
        if groupedselection.keys.count <= 1 {
            return .init(
                options: .singleSelection,
                children: selection.map { buildMenuItemWithSelectionItem($0) }
            )
        } else if selection.count <= 10 {
            return .init(
                options: .singleSelection,
                children: groupedselection.map { section, items in
                    UIMenu(
                        title: section,
                        options: .displayInline,
                        children: items.map { buildMenuItemWithSelectionItem($0) }
                    )
                }
            )
        } else {
            return .init(
                options: .singleSelection,
                children: groupedselection.map { section, items in
                    UIMenu(
                        title: section,
                        options: section.isEmpty ? [.displayInline] : [],
                        children: items.map { buildMenuItemWithSelectionItem($0) }
                    )
                }
            )
        }
    }

    func buildMenuItemWithSelectionItem(_ selectionItem: ListAnnotation.ValueItem) -> UIMenuElement {
        UIDeferredMenuElement.uncached { [weak self] completion in
            let icon: UIImage? = if selectionItem.icon.isEmpty {
                nil
            } else if selectionItem.icon.hasPrefix("#") {
                UIImage(named: String(selectionItem.icon.dropFirst()))
            } else {
                UIImage(systemName: selectionItem.icon)
            }

            let action = UIAction(
                title: selectionItem.title,
                image: icon
            ) { [weak self] _ in
                self?.value = selectionItem.rawValue
            }

            if selectionItem.rawValue == self?.value {
                action.state = .on
            } else {
                action.state = .off
            }

            completion([action])
        }
    }
}
