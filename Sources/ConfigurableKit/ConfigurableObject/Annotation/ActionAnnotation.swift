//
//  ActionAnnotation.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 2025/1/5.
//

import Foundation

open class ActionAnnotation: ConfigurableObject.AnnotationProtocol {
    let handler: @MainActor (CKViewController) async -> Void

    public init(handler: @escaping @MainActor (CKViewController) async -> Void) {
        self.handler = handler
    }

    @MainActor
    public func createView(fromObject _: ConfigurableObject) -> ConfigurableView {
        ConfigurableActionView(actionBlock: handler)
    }
}
