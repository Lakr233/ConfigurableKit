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
    public init(
        dataSource: some ObjectListDataSource,
        delegate: ObjectListViewControllerDelegate? = nil
    ) {
        viewControllerFactory = {
            let vc = ObjectListViewController(dataSource: dataSource)
            vc.delegate = delegate
            return vc
        }
    }

    @MainActor
    public func createView(fromObject _: ConfigurableObject) -> ConfigurableView {
        ConfigurablePageView(page: viewControllerFactory)
    }
}
