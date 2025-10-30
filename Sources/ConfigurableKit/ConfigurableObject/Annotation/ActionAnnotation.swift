//
//  ActionAnnotation.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 2025/1/5.
//

import UIKit

open class ActionAnnotation: ConfigurableObject.AnnotationProtocol {
    let handler: @MainActor (UIViewController) async -> Void

    public init(handler: @escaping @MainActor (UIViewController) async -> Void) {
        self.handler = handler
    }

    @MainActor
    public func createView(fromObject _: ConfigurableObject) -> ConfigurableView {
        ConfigurableActionView(actionBlock: handler)
    }
}
