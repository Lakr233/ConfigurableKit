//
//  ObjectListContext.swift
//  ConfigurableKit
//
//  Context object passed to custom view controllers for saving items.
//

import UIKit

@MainActor
public final class ObjectListContext<Item> {
    weak var viewController: UIViewController?
    private let onSave: (Item) -> Void

    init(onSave: @escaping (Item) -> Void) {
        self.onSave = onSave
    }

    public func save(_ item: Item, dismiss: Bool = true) {
        onSave(item)
        if dismiss {
            if let nav = viewController?.navigationController {
                nav.popViewController(animated: true)
            } else {
                viewController?.dismiss(animated: true)
            }
        }
    }
}
