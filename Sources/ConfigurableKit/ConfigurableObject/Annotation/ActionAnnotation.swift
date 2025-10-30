//
//  ActionAnnotation.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 2025/1/5.
//

import UIKit

open class ActionAnnotation: ConfigurableObject.AnnotationProtocol {
    let handler: (UIViewController) -> Void

    public init(handler: @escaping (UIViewController) -> Void) {
        self.handler = handler
    }

    @MainActor
    public func createView(fromObject _: ConfigurableObject) -> ConfigurableView {
        ConfigurableActionView(actionBlock: handler)
    }
}
