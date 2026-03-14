//
//  ShareAnnotation.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 2025/1/5.
//

import UIKit

open class ShareAnnotation: ConfigurableObject.AnnotationProtocol {
    public let title: String.LocalizationValue
    public let url: URL

    public init(title: String.LocalizationValue, url: URL) {
        self.title = title
        self.url = url
    }

    @_disfavoredOverload
    public convenience init(title: String, url: URL) {
        self.init(title: String.LocalizationValue(title), url: url)
    }

    @MainActor
    public func createView(fromObject _: ConfigurableObject) -> ConfigurableView {
        ConfigurableShareView(buttonTitle: title, url: url)
    }
}
