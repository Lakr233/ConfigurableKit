#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    import AppKit

    @MainActor
    public protocol ConfigurableViewControllerDelegate: AnyObject {
        func configurableViewControllerDidLoad(_ controller: ConfigurableViewController)
        func configurableViewControllerWillAppear(_ controller: ConfigurableViewController)
        func configurableViewControllerDidAppear(_ controller: ConfigurableViewController)

        func configurableViewController(
            _ controller: ConfigurableViewController,
            configureLeadingBarButtonItems items: inout [NSMenuItem]
        )
        func configurableViewController(
            _ controller: ConfigurableViewController,
            configureTrailingBarButtonItems items: inout [NSMenuItem]
        )
        func configurableViewController(
            _ controller: ConfigurableViewController,
            configureToolbarItems items: inout [NSMenuItem]
        )
    }

    public extension ConfigurableViewControllerDelegate {
        func configurableViewControllerDidLoad(_: ConfigurableViewController) {}
        func configurableViewControllerWillAppear(_: ConfigurableViewController) {}
        func configurableViewControllerDidAppear(_: ConfigurableViewController) {}
        func configurableViewController(_: ConfigurableViewController, configureLeadingBarButtonItems _: inout [NSMenuItem]) {}
        func configurableViewController(_: ConfigurableViewController, configureTrailingBarButtonItems _: inout [NSMenuItem]) {}
        func configurableViewController(_: ConfigurableViewController, configureToolbarItems _: inout [NSMenuItem]) {}
    }
#endif
