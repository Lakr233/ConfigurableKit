//
//  OpenLinkAnnotation.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 2025/1/5.
//

import UIKit

open class OpenLinkAnnotation: ConfigurableObject.AnnotationProtocol {
    public let title: String.LocalizationValue
    public let url: URL

    public init(title: String.LocalizationValue, url: URL) {
        self.title = title
        self.url = url
    }

    @MainActor
    public func createView(fromObject _: ConfigurableObject) -> ConfigurableView {
        ConfigurableLinkView(buttonTitle: title, url: url)
    }
}
