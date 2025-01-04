//
//  ShareLinkAnnotation.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 2025/1/5.
//

import UIKit

open class ShareLinkAnnotation: ConfigurableObject.AnnotationProtocol {
    let title: String
    let url: URL

    init(title: String, url: URL) {
        self.title = title
        self.url = url
    }

    public func createView(fromObject _: ConfigurableObject) -> ConfigurableView {
        ConfigurableShareLinkView(buttonTitle: title, url: url)
    }
}
