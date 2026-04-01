//
//  PageAnnotation.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 2025/1/5.
//

import Foundation

open class PageAnnotation: ConfigurableObject.AnnotationProtocol {
    let viewController: () -> (CKViewController?)

    public init(viewController: @escaping () -> (CKViewController?)) {
        self.viewController = viewController
    }

    @MainActor
    public func createView(fromObject _: ConfigurableObject) -> ConfigurableView {
        ConfigurablePageView(page: viewController)
    }
}
