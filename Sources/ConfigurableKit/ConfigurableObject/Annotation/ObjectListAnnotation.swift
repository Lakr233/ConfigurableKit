//
//  ObjectListAnnotation.swift
//  ConfigurableKit
//
//  Annotation that presents an ObjectListViewController when tapped.
//  Renders as a page-push chevron row using ConfigurablePageView.
//

import UIKit

open class ObjectListAnnotation: ConfigurableObject.AnnotationProtocol {
    let viewControllerFactory: @MainActor () -> UIViewController

    @MainActor
    public init(dataSource: some ObjectListDataSource) {
        viewControllerFactory = {
            ObjectListViewController(dataSource: dataSource)
        }
    }

    @MainActor
    public func createView(fromObject _: ConfigurableObject) -> ConfigurableView {
        ConfigurablePageView(page: viewControllerFactory)
    }
}
