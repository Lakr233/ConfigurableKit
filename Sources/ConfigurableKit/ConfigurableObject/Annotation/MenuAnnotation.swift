//
//  MenuAnnotation.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 2025/1/5.
//

import Foundation

open class MenuAnnotation: ConfigurableObject.AnnotationProtocol {
    let selections: () -> [MenuAnnotation.Option]
    init(selections: @escaping (() -> [MenuAnnotation.Option])) {
        self.selections = selections
    }

    @MainActor
    public func createView(fromObject object: ConfigurableObject) -> ConfigurableView {
        ConfigurableSelectView(storage: object.valueStorage, selection: selections)
    }
}

public extension MenuAnnotation {
    struct Option: Codable {
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

public extension MenuAnnotation.Option {
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
