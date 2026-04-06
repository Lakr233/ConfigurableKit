//
//  ConfigurableManifest.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 2025/1/5.
//

import Foundation
#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#endif

open class ConfigurableManifest {
    public var title: String.LocalizationValue
    public var list: [ConfigurableObject]
    public var footer: CKView

    @MainActor
    public init(
        title: String.LocalizationValue? = nil,
        list: [ConfigurableObject],
        footer: CKView = .init()
    ) {
        self.title = title ?? String.LocalizationValue("Settings")
        self.list = list
        self.footer = footer
    }
}

public extension ConfigurableManifest {
    @MainActor
    convenience init(
        title: String.LocalizationValue? = nil,
        list: [ConfigurableObject],
        footer: String.LocalizationValue
    ) {
        let localizedFooter = String(localized: footer)
        #if canImport(UIKit)
            let label = UILabel()
            label.numberOfLines = 0
            label.font = .preferredFont(forTextStyle: .footnote)
            label.alpha = 0.5
            label.textColor = .label
            label.text = localizedFooter
            label.textAlignment = .center
            self.init(title: title, list: list, footer: label)
        #elseif canImport(AppKit)
            let label = NSTextField(labelWithString: localizedFooter)
            label.maximumNumberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.font = .systemFont(ofSize: NSFont.smallSystemFontSize)
            label.textColor = .secondaryLabelColor
            label.alignment = .center
            label.alphaValue = 0.5
            self.init(title: title, list: list, footer: label)
        #endif
    }
}
