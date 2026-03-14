//
//  ObjectListViewControllerDelegate.swift
//  ConfigurableKit
//

import UIKit

@MainActor
public protocol ObjectListViewControllerDelegate: AnyObject {
    /// Called after the view controller has loaded its view.
    func objectListViewControllerDidLoad(_ controller: UIViewController)

    /// Customize the leading navigation bar button items.
    func objectListViewController(
        _ controller: UIViewController,
        configureLeadingBarButtonItems items: inout [UIBarButtonItem]
    )

    /// Customize the trailing navigation bar button items.
    func objectListViewController(
        _ controller: UIViewController,
        configureTrailingBarButtonItems items: inout [UIBarButtonItem]
    )

    /// Customize the toolbar items shown during editing mode.
    func objectListViewController(
        _ controller: UIViewController,
        configureToolbarItems items: inout [UIBarButtonItem]
    )

    /// Build additional context menu actions for a given item identifier.
    func objectListViewController(
        _ controller: UIViewController,
        contextMenuActionsForItemWith id: UUID
    ) -> [UIMenuElement]
}

public extension ObjectListViewControllerDelegate {
    func objectListViewControllerDidLoad(_: UIViewController) {}
    func objectListViewController(_: UIViewController, configureLeadingBarButtonItems _: inout [UIBarButtonItem]) {}
    func objectListViewController(_: UIViewController, configureTrailingBarButtonItems _: inout [UIBarButtonItem]) {}
    func objectListViewController(_: UIViewController, configureToolbarItems _: inout [UIBarButtonItem]) {}
    func objectListViewController(_: UIViewController, contextMenuActionsForItemWith _: UUID) -> [UIMenuElement] {
        []
    }
}
