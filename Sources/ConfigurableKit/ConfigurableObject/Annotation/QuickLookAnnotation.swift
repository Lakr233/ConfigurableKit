//
//  QuickLookAnnotation.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 2025/1/5.
//

import UIKit

open class QuickLookAnnotation: ConfigurableObject.AnnotationProtocol {
    public let title: String.LocalizationValue
    public let url: URL

    public init(title: String.LocalizationValue, url: URL) {
        self.title = title
        self.url = url
    }

    @MainActor
    public func createView(fromObject _: ConfigurableObject) -> ConfigurableView {
        ConfigurableQuickLookView(buttonTitle: title, url: url)
    }
}
