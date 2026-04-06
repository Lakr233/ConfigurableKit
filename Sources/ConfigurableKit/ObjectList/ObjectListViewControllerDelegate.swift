//
//  ObjectListViewControllerDelegate.swift
//  ConfigurableKit
//

import Foundation

#if canImport(UIKit)
    import UIKit

    public typealias ObjectListBarButtonItem = UIBarButtonItem
    public typealias ObjectListMenuElement = UIMenuElement
#elseif canImport(AppKit)
    import AppKit

    public typealias ObjectListBarButtonItem = NSMenuItem
    public typealias ObjectListMenuElement = NSMenuItem
#endif

@MainActor
public protocol ObjectListViewControllerDelegate: AnyObject {
    /// Called after the view controller has loaded its view.
    func objectListViewControllerDidLoad(_ controller: CKViewController)

    /// Customize the leading navigation bar button items.
    func objectListViewController(
        _ controller: CKViewController,
        configureLeadingBarButtonItems items: inout [ObjectListBarButtonItem]
    )

    /// Customize the trailing navigation bar button items.
    func objectListViewController(
        _ controller: CKViewController,
        configureTrailingBarButtonItems items: inout [ObjectListBarButtonItem]
    )

    /// Customize the toolbar items shown during editing mode.
    func objectListViewController(
        _ controller: CKViewController,
        configureToolbarItems items: inout [ObjectListBarButtonItem]
    )

    /// Build additional context menu actions for a given item identifier.
    func objectListViewController(
        _ controller: CKViewController,
        contextMenuActionsForItemWith id: UUID
    ) -> [ObjectListMenuElement]
}

public extension ObjectListViewControllerDelegate {
    func objectListViewControllerDidLoad(_: CKViewController) {}
    func objectListViewController(_: CKViewController, configureLeadingBarButtonItems _: inout [ObjectListBarButtonItem]) {}
    func objectListViewController(_: CKViewController, configureTrailingBarButtonItems _: inout [ObjectListBarButtonItem]) {}
    func objectListViewController(_: CKViewController, configureToolbarItems _: inout [ObjectListBarButtonItem]) {}
    func objectListViewController(_: CKViewController, contextMenuActionsForItemWith _: UUID) -> [ObjectListMenuElement] {
        []
    }
}
