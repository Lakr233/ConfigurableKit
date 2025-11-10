//
//  ConfigSectionModels.swift
//  ConfigurableKit
//
//  Created by GPT-5 Codex on 2025/11/10.
//

import Foundation

public struct ConfigSectionNode {
    public var id: AnyHashable
    public var header: ConfigSectionHeader?
    public var footer: ConfigSectionFooter?
    public var elements: [ConfigElementNode]
    public var isVisible: Bool

    public init(
        id: AnyHashable,
        header: ConfigSectionHeader? = nil,
        footer: ConfigSectionFooter? = nil,
        elements: [ConfigElementNode],
        isVisible: Bool = true
    ) {
        self.id = id
        self.header = header
        self.footer = footer
        self.elements = elements
        self.isVisible = isVisible
    }
}

public struct ConfigSectionHeader {
    public var title: String?
    public var subtitle: String?
    public var iconSystemName: String?

    public init(title: String?, subtitle: String? = nil, iconSystemName: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.iconSystemName = iconSystemName
    }
}

public struct ConfigSectionFooter {
    public var text: String
    public var iconSystemName: String?

    public init(text: String, iconSystemName: String? = nil) {
        self.text = text
        self.iconSystemName = iconSystemName
    }
}

public struct ConfigElementNode {
    public var id: AnyHashable
    public var kind: ConfigElementKind
    public var isVisible: Bool

    public init(id: AnyHashable, kind: ConfigElementKind, isVisible: Bool = true) {
        self.id = id
        self.kind = kind
        self.isVisible = isVisible
    }
}

public enum ConfigElementKind {
    case toggle(ConfigToggleElement)
    case action(ConfigActionElement)
    case info(ConfigInfoElement)
    case picker(AnyConfigPickerElement)
}
