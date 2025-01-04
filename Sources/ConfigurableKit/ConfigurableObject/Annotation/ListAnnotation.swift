//
//  ListAnnotation.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 2025/1/5.
//

import ConfigurableKitAnyCodable
import UIKit

open class ListAnnotation: ConfigurableObject.AnnotationProtocol {
    let selections: [ValueItem]
    init(selections: [ValueItem]) {
        self.selections = selections
    }

    public func createView(fromObject object: ConfigurableObject) -> ConfigurableView {
        ConfigurableMenuView(storage: object.__value, selection: selections)
    }
}

public extension ListAnnotation {
    struct ValueItem: Codable {
        let icon: String
        let title: String
        let section: String
        let rawValue: AnyCodable // used for callback

        public init(
            icon: String = "",
            title: String,
            section: String = "",
            rawValue: AnyCodable
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
        title: String,
        section: String = "",
        rawValue: some Codable
    ) {
        self.icon = icon
        self.title = title
        self.section = section
        self.rawValue = .init(rawValue)
    }
}
