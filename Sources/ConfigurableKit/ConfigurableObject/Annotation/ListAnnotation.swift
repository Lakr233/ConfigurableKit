//
//  ListAnnotation.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 2025/1/5.
//

import UIKit

open class ListAnnotation: ConfigurableObject.AnnotationProtocol {
    let selections: () -> [ListAnnotation.ValueItem]
    init(selections: @escaping (() -> [ListAnnotation.ValueItem])) {
        self.selections = selections
    }

    @MainActor
    public func createView(fromObject object: ConfigurableObject) -> ConfigurableView {
        ConfigurableMenuView(storage: object.__value, selection: selections)
    }
}

public extension ListAnnotation {
    struct ValueItem: Codable {
        public let icon: String
        public let title: String.LocalizationValue
        public let section: String.LocalizationValue
        public let rawValue: ConfigurableKitAnyCodable // used for callback

        public init(
            icon: String = "",
            title: String.LocalizationValue,
            section: String.LocalizationValue = "",
            rawValue: ConfigurableKitAnyCodable
        ) {
            self.icon = icon
            self.title = title
            self.section = section
            self.rawValue = rawValue
        }
    }
}

public extension ListAnnotation.ValueItem {
    init(
        icon: String = "",
        title: String.LocalizationValue,
        section: String.LocalizationValue = "",
        rawValue: some Codable
    ) {
        self.icon = icon
        self.title = title
        self.section = section
        self.rawValue = .init(rawValue)
    }
}
