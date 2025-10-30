//
//  ConfigurableManifest.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 2025/1/5.
//

import Foundation
import UIKit

open class ConfigurableManifest {
    public let title: String.LocalizationValue
    public let list: [ConfigurableObject]
    public let footer: UIView

    public init(
        title: String.LocalizationValue? = nil,
        list: [ConfigurableObject],
        footer: UIView = .init()
    ) {
        self.title = title ?? String.LocalizationValue("Settings")
        self.list = list
        self.footer = footer
    }
}

public extension ConfigurableManifest {
    convenience init(
        title: String.LocalizationValue? = nil,
        list: [ConfigurableObject],
        footer: String.LocalizationValue
    ) {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .footnote)
        label.alpha = 0.5
        label.textColor = .label
        label.text = footer
        label.textAlignment = .center
        self.init(title: title, list: list, footer: label)
    }
}
