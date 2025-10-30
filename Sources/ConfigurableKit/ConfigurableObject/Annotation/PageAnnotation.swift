//
//  PageAnnotation.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 2025/1/5.
//

import UIKit

open class PageAnnotation: ConfigurableObject.AnnotationProtocol {
    let viewController: () -> (UIViewController?)

    public init(viewController: @escaping () -> (UIViewController?)) {
        self.viewController = viewController
    }

    @MainActor
    public func createView(fromObject _: ConfigurableObject) -> ConfigurableView {
        ConfigurablePageView(page: viewController)
    }
}
