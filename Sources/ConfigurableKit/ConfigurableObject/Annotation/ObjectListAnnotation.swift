//
//  ObjectListAnnotation.swift
//  ConfigurableKit
//
//  Annotation that presents an ObjectListViewController when tapped.
//  Renders as a page-push chevron row using ConfigurablePageView.
//

import Foundation

open class ObjectListAnnotation: ConfigurableObject.AnnotationProtocol {
    let viewControllerFactory: @MainActor () -> CKViewController
    let presentationStyle: ConfigurablePagePresentationStyle

    @MainActor
    public init(
        dataSource: some ObjectListDataSource,
        delegate: ObjectListViewControllerDelegate? = nil,
        presentationStyle: ConfigurablePagePresentationStyle = .push
    ) {
        self.presentationStyle = presentationStyle
        viewControllerFactory = {
            let vc = ObjectListViewController(dataSource: dataSource)
            vc.delegate = delegate
            return vc
        }
    }

    @MainActor
    public init(
        viewController: @MainActor @escaping () -> CKViewController,
        presentationStyle: ConfigurablePagePresentationStyle = .push
    ) {
        self.presentationStyle = presentationStyle
        viewControllerFactory = viewController
    }

    @MainActor
    public init<Item>(
        onSave: @MainActor @escaping (Item) -> Void,
        viewController: @MainActor @escaping (ObjectListContext<Item>) -> CKViewController,
        presentationStyle: ConfigurablePagePresentationStyle = .push
    ) {
        self.presentationStyle = presentationStyle
        viewControllerFactory = {
            let context = ObjectListContext<Item>(onSave: onSave)
            let vc = viewController(context)
            context.viewController = vc
            return vc
        }
    }

    @MainActor
    public func createView(fromObject _: ConfigurableObject) -> ConfigurableView {
        ConfigurablePageView(
            page: viewControllerFactory,
            presentationStyle: presentationStyle
        )
    }
}
