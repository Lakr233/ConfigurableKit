//
//  Annotation.swift
//  TRApp
//
//  Created by 82Flex on 2024/11/7.
//

import Foundation
import UIKit

public extension ConfigurableObject {
    typealias AnyAnnotation = any AnnotationProtocol

    enum Annotation {
        case submenu(children: () -> [ConfigurableObject])

        case boolean
        case list(selections: [ListAnnotation.ValueItem])
        case page(viewController: () -> (UIViewController))
        case action(handler: (UIViewController?) -> Void)

        case openLink(title: String, url: URL)
        case quickLook(title: String, url: URL)
        case shareLink(title: String, url: URL)

        // use custom view as entire cell, ignore other items
        case custom(view: () -> (UIView))

        var mapObject: AnyAnnotation {
            switch self {
            case let .submenu(children): SubmenuAnnotation(children: children)
            case .boolean: BooleanAnnotation()
            case let .list(selections): ListAnnotation(selections: selections)
            case let .page(viewController): PageAnnotation(viewController: viewController)
            case let .action(handler): ActionAnnotation(handler: handler)
            case let .openLink(title, url): OpenLinkAnnotation(title: title, url: url)
            case let .quickLook(title, url): QuickLookAnnotation(title: title, url: url)
            case let .shareLink(title, url): ShareLinkAnnotation(title: title, url: url)
            case let .custom(view): CustomViewAnnotation(view: view)
            }
        }
    }
}

public extension ConfigurableObject {
    protocol AnnotationProtocol: AnyObject {
        func createView(fromObject object: ConfigurableObject) -> ConfigurableView
    }
}
