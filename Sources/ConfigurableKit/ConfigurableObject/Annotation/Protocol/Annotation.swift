//
//  Annotation.swift
//  ConfigurableKit
//
//  Created by 82Flex on 2024/11/7.
//

import Foundation

public extension ConfigurableObject {
    typealias AnyAnnotation = any AnnotationProtocol

    enum Annotation {
        case submenu(children: () -> [ConfigurableObject])

        case toggle
        case textInput(placeholder: String = "")
        case menu(selections: () -> [MenuAnnotation.Option])
        case page(viewController: () -> (CKViewController))
        case action(handler: @MainActor (CKViewController) async -> Void)

        case link(title: String.LocalizationValue, url: URL)
        case quickLook(title: String.LocalizationValue, url: URL)
        case share(title: String.LocalizationValue, url: URL)

        /// use custom view as entire cell, ignore other items
        case custom(view: () -> (CKView))

        func createAnnotation() -> AnyAnnotation {
            switch self {
            case let .submenu(children): SubmenuAnnotation(children: children)
            case .toggle: ToggleAnnotation()
            case let .textInput(placeholder): TextInputAnnotation(placeholder: placeholder)
            case let .menu(selections): MenuAnnotation(selections: selections)
            case let .page(viewController): PageAnnotation(viewController: viewController)
            case let .action(handler): ActionAnnotation(handler: handler)
            case let .link(title, url): LinkAnnotation(title: title, url: url)
            case let .quickLook(title, url): QuickLookAnnotation(title: title, url: url)
            case let .share(title, url): ShareAnnotation(title: title, url: url)
            case let .custom(view): CustomAnnotation(view: view)
            }
        }
    }
}

public extension ConfigurableObject {
    protocol AnnotationProtocol {
        @MainActor
        func createView(fromObject object: ConfigurableObject) -> ConfigurableView
    }
}

extension ConfigurableObject.Annotation: ConfigurableObject.AnnotationProtocol {
    @MainActor
    public func createView(fromObject object: ConfigurableObject) -> ConfigurableView {
        createAnnotation().createView(fromObject: object)
    }
}
