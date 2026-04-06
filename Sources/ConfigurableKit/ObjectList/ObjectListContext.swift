//
//  ObjectListContext.swift
//  ConfigurableKit
//
//  Context object passed to custom view controllers for saving items.
//

import Foundation

@MainActor
public final class ObjectListContext<Item> {
    weak var viewController: CKViewController?
    private let onSave: (Item) -> Void

    init(onSave: @escaping (Item) -> Void) {
        self.onSave = onSave
    }

    public func save(_ item: Item, dismiss: Bool = true) {
        onSave(item)
        if dismiss {
            viewController?.ckClose(animated: true)
        }
    }
}
