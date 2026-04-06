#if canImport(UIKit)
//
    //  ConfigurableViewControllerDelegate.swift
    //  ConfigurableKit
//
    //  Delegate protocol for customizing ConfigurableViewController behavior.
//

    import UIKit

    @MainActor
    public protocol ConfigurableViewControllerDelegate: AnyObject {
        func configurableViewControllerDidLoad(_ controller: ConfigurableViewController)
        func configurableViewControllerWillAppear(_ controller: ConfigurableViewController)
        func configurableViewControllerDidAppear(_ controller: ConfigurableViewController)

        func configurableViewController(
            _ controller: ConfigurableViewController,
            configureLeadingBarButtonItems items: inout [UIBarButtonItem]
        )
        func configurableViewController(
            _ controller: ConfigurableViewController,
            configureTrailingBarButtonItems items: inout [UIBarButtonItem]
        )
        func configurableViewController(
            _ controller: ConfigurableViewController,
            configureToolbarItems items: inout [UIBarButtonItem]
        )
    }

    public extension ConfigurableViewControllerDelegate {
        func configurableViewControllerDidLoad(_: ConfigurableViewController) {}
        func configurableViewControllerWillAppear(_: ConfigurableViewController) {}
        func configurableViewControllerDidAppear(_: ConfigurableViewController) {}
        func configurableViewController(_: ConfigurableViewController, configureLeadingBarButtonItems _: inout [UIBarButtonItem]) {}
        func configurableViewController(_: ConfigurableViewController, configureTrailingBarButtonItems _: inout [UIBarButtonItem]) {}
        func configurableViewController(_: ConfigurableViewController, configureToolbarItems _: inout [UIBarButtonItem]) {}
    }
#endif
