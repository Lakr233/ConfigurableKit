//
//  OpenLinkAnnotation.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 2025/1/5.
//

import UIKit

open class OpenLinkAnnotation: ConfigurableObject.AnnotationProtocol {
    let title: String
    let url: URL

    init(title: String, url: URL) {
        self.title = title
        self.url = url
    }

    public func createView(fromObject _: ConfigurableObject) -> ConfigurableView {
        ConfigurableLinkView(buttonTitle: title, url: url)
    }
}