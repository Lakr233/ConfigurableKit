//
//  ConfigBuilders.swift
//  ConfigurableKit
//
//  Created by GPT-5 Codex on 2025/11/10.
//

import Foundation

@MainActor
@resultBuilder
public enum ConfigContentBuilder {
    public static func buildBlock(_ components: [ConfigSectionNode]...) -> [ConfigSectionNode] {
        components.flatMap(\.self)
    }

    public static func buildOptional(_ component: [ConfigSectionNode]?) -> [ConfigSectionNode] {
        component ?? []
    }

    public static func buildEither(first component: [ConfigSectionNode]) -> [ConfigSectionNode] {
        component
    }

    public static func buildEither(second component: [ConfigSectionNode]) -> [ConfigSectionNode] {
        component
    }

    public static func buildArray(_ components: [[ConfigSectionNode]]) -> [ConfigSectionNode] {
        components.flatMap(\.self)
    }

    public static func buildExpression(_ expression: ConfigSectionNode) -> [ConfigSectionNode] {
        [expression]
    }

    public static func buildExpression(_ expression: ConfigSection) -> [ConfigSectionNode] {
        [expression.makeSectionNode()]
    }

    public static func buildLimitedAvailability(_ component: [ConfigSectionNode]) -> [ConfigSectionNode] {
        component
    }
}

@MainActor
@resultBuilder
public enum ConfigElementBuilder {
    public static func buildBlock(_ components: [ConfigElementNode]...) -> [ConfigElementNode] {
        components.flatMap(\.self)
    }

    public static func buildOptional(_ component: [ConfigElementNode]?) -> [ConfigElementNode] {
        component ?? []
    }

    public static func buildEither(first component: [ConfigElementNode]) -> [ConfigElementNode] {
        component
    }

    public static func buildEither(second component: [ConfigElementNode]) -> [ConfigElementNode] {
        component
    }

    public static func buildArray(_ components: [[ConfigElementNode]]) -> [ConfigElementNode] {
        components.flatMap(\.self)
    }

    public static func buildExpression(_ expression: ConfigElementNode) -> [ConfigElementNode] {
        [expression]
    }

    public static func buildExpression(_ expression: ConfigElementConvertible) -> [ConfigElementNode] {
        [expression.makeElementNode()]
    }

    public static func buildLimitedAvailability(_ component: [ConfigElementNode]) -> [ConfigElementNode] {
        component
    }
}

@MainActor
public protocol ConfigPage {
    @ConfigContentBuilder
    var body: [ConfigSectionNode] { get }
}

public extension ConfigPage {
    func makeSections() -> [ConfigSectionNode] {
        body
    }
}

@MainActor
public struct ConfigSection {
    private var node: ConfigSectionNode

    public init(
        _ title: String? = nil,
        id: AnyHashable? = nil,
        isVisible: Bool = true,
        @ConfigElementBuilder content: () -> [ConfigElementNode]
    ) {
        let resolvedId: AnyHashable = id ?? AnyHashable(title ?? UUID().uuidString)
        let header = title.map { ConfigSectionHeader(title: $0) }
        let elements = content()
        node = ConfigSectionNode(id: resolvedId, header: header, elements: elements, isVisible: isVisible)
    }

    private init(node: ConfigSectionNode) {
        self.node = node
    }

    public func headerSubtitle(_ text: String?) -> ConfigSection {
        var copy = node
        if let existing = copy.header {
            copy.header = ConfigSectionHeader(title: existing.title, subtitle: text, iconSystemName: existing.iconSystemName)
        } else {
            copy.header = ConfigSectionHeader(title: nil, subtitle: text)
        }
        return ConfigSection(node: copy)
    }

    public func headerIcon(_ systemName: String?) -> ConfigSection {
        var copy = node
        if let existing = copy.header {
            copy.header = ConfigSectionHeader(title: existing.title, subtitle: existing.subtitle, iconSystemName: systemName)
        } else {
            copy.header = ConfigSectionHeader(title: nil, subtitle: nil, iconSystemName: systemName)
        }
        return ConfigSection(node: copy)
    }

    public func footer(_ text: String, iconSystemName: String? = nil) -> ConfigSection {
        var copy = node
        copy.footer = ConfigSectionFooter(text: text, iconSystemName: iconSystemName)
        return ConfigSection(node: copy)
    }

    public func visible(_ isVisible: Bool) -> ConfigSection {
        var copy = node
        copy.isVisible = isVisible
        return ConfigSection(node: copy)
    }

    public func identified(by id: AnyHashable) -> ConfigSection {
        var copy = node
        copy.id = id
        return ConfigSection(node: copy)
    }

    func makeSectionNode() -> ConfigSectionNode {
        node
    }
}

@MainActor
public protocol ConfigElementConvertible {
    func makeElementNode() -> ConfigElementNode
}

public typealias Section = ConfigSection
