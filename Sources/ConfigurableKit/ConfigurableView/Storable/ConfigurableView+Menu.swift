//
//  ConfigurableView+Menu.swift
//  TRApp
//
//  Created by 82Flex on 2024/9/14.
//

import Combine
import OrderedCollections
import UIKit

open class ConfigurableMenuView: ConfigurableValueView {
    open var button: EasyHitButton { contentView as! EasyHitButton }
    let selection: () -> [ListAnnotation.ValueItem]

    public init(storage: CodableStorage, selection: @escaping () -> [ListAnnotation.ValueItem]) {
        self.selection = selection
        super.init(storage: storage)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.contentHorizontalAlignment = .trailing
        button.showsMenuAsPrimaryAction = true
        rebuildMenu()
    }

    override open class func createContentView() -> UIView {
        EasyHitButton()
    }

    override open func updateValue() {
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

    open func executeUpdateValue(_ value: ConfigurableKitAnyCodable) {
        let selection = selection()

        var text: String = value.decodingValue(defaultValue: String(describing: value))
        for item in selection where item.rawValue == value {
            text = item.title
            break
        }

        if text.isEmpty { text = String.LocalizationValue("Unspecified") }

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

        rebuildMenu()
    }

    func rebuildMenu() {
        let selections = selection()
        let item = menuWithSelection(selections)
        button.menu = .init(
            options: [.displayInline],
            children: item
        )
    }

    open func menuWithSelection(_ selection: [ListAnnotation.ValueItem]) -> [UIMenuElement] {
        let groupedselection: OrderedDictionary<String, [ListAnnotation.ValueItem]>
        groupedselection = selection.reduce(into: [:]) { result, item in
            result[item.section, default: []].append(item)
        }
        // if section is all empty, return UIActions directly
        if groupedselection.keys.allSatisfy(\.isEmpty) {
            return groupedselection.values.flatMap {
                $0.map { menuItemWithSelection($0) }
            }
        }

        var displayOptions: UIMenu.Options = []
        if selection.count <= 10 || groupedselection.keys.count == 1 {
            displayOptions.insert(.displayInline)
        }

        return groupedselection.map { section, items in
            var options = displayOptions
            if section.isEmpty { options.insert(.displayInline) }
            return UIMenu(
                title: section,
                options: options,
                children: items.map { menuItemWithSelection($0) }
            )
        }
    }

    open func menuItemWithSelection(_ selectionItem: ListAnnotation.ValueItem) -> UIMenuElement {
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
        if selectionItem.rawValue == value {
            action.state = .on
        } else {
            action.state = .off
        }
        return action
    }
}
