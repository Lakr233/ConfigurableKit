//
//  ConfigurableView+Link.swift
//  TRApp
//
//  Created by 82Flex on 2024/9/14.
//

import Combine
import UIKit

open class ConfigurableLinkView: ConfigurableView {
    let url: URL

    var button: EasyHitButton { contentView as! EasyHitButton }

    public init(buttonTitle: String, url: URL) {
        self.url = url

        super.init()

        let attrString = NSAttributedString(string: buttonTitle, attributes: [
            .foregroundColor: UIColor.accent,
            .font: UIFont.preferredFont(forTextStyle: .subheadline).semibold,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
        ])

        let pressedAttrString = NSAttributedString(string: buttonTitle, attributes: [
            .foregroundColor: UIColor.accent.withAlphaComponent(0.5),
            .font: UIFont.preferredFont(forTextStyle: .subheadline).semibold,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
        ])

        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.addTarget(self, action: #selector(openURL), for: .touchUpInside)
        button.contentHorizontalAlignment = .trailing

        button.setAttributedTitle(attrString, for: .normal)
        button.setAttributedTitle(pressedAttrString, for: .highlighted)
        button.setAttributedTitle(pressedAttrString, for: .disabled)
        button.setAttributedTitle(pressedAttrString, for: .selected)
    }

    @available(*, unavailable)
    public required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open class func createContentView() -> UIView {
        EasyHitButton()
    }

    @objc func openURL() {
        UIApplication.shared.open(url)
    }
}
