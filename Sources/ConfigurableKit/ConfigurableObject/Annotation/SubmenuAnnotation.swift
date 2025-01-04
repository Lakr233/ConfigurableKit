//
//  SubmenuAnnotation.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 2025/1/5.
//

import UIKit

open class SubmenuAnnotation: ConfigurableObject.AnnotationProtocol {
    let children: () -> [ConfigurableObject]
    init(children: @escaping () -> [ConfigurableObject]) {
        self.children = children
    }

    public func createView(fromObject _: ConfigurableObject) -> ConfigurableView {
        ConfigurableSubmenuView(childrenReader: children)
    }
}
