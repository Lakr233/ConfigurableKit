#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    import AppKit
    import QuartzCore

    open class ConfigurableSheetController: NSViewController, NSToolbarDelegate {
        @MainActor
        public protocol NavigationItemMenuProviding: AnyObject {
            func navigationChromeLeadingItems(for sheetController: ConfigurableSheetController) -> [NSMenuItem]
            func navigationChromeTrailingItems(for sheetController: ConfigurableSheetController) -> [NSMenuItem]
        }

        public let controller: ConfigurableViewController
        private var navigationStack: [NSViewController]
        private enum NavigationTransitionDirection {
            case none
            case forward
            case backward
        }

        override open var title: String? {
            get { controller.title }
            set {
                controller.title = newValue
                if navigationStack.first === controller {
                    updateNavigationChrome()
                }
            }
        }

        private static let toolbarIdentifier = NSToolbar.Identifier("ConfigurableSheetController.toolbar")
        private static let backToolbarItemIdentifier = NSToolbarItem.Identifier("ConfigurableSheetController.back")
        private static let titleToolbarItemIdentifier = NSToolbarItem.Identifier("ConfigurableSheetController.title")
        private static let actionsToolbarItemIdentifier = NSToolbarItem.Identifier("ConfigurableSheetController.actions")

        private lazy var toolbar: NSToolbar = {
            let toolbar = NSToolbar(identifier: Self.toolbarIdentifier)
            toolbar.delegate = self
            toolbar.allowsUserCustomization = false
            toolbar.autosavesConfiguration = false
            toolbar.displayMode = .iconOnly
            if #available(macOS 11.0, *) {
                toolbar.showsBaselineSeparator = false
            }
            if #available(macOS 13.0, *) {
                toolbar.centeredItemIdentifiers = [Self.titleToolbarItemIdentifier]
            }
            return toolbar
        }()

        private let titleLabel = NSTextField(labelWithString: "")
        private let trailingActionMenu = NSMenu()
        private weak var actionsMenuToolbarItem: NSMenuToolbarItem?
        private let trailingToolbarItem: NSToolbarItem?
        private let rootScrollView = NSScrollView()
        private let rootDocumentView = NSView()
        private let containerView = NSView()
        private weak var mountedController: NSViewController?
        private var escapeEventMonitor: Any?
        public var onRequestClose: (@MainActor (ConfigurableSheetController) -> Void)?

        public init(
            manifest: ConfigurableManifest,
            trailingToolbarItem: NSToolbarItem? = nil
        ) {
            controller = .init(manifest: manifest)
            navigationStack = [controller]
            self.trailingToolbarItem = trailingToolbarItem
            super.init(nibName: nil, bundle: nil)
            preferredContentSize = .init(width: 555, height: 555)
        }

        private var actionsItemIdentifier: NSToolbarItem.Identifier {
            trailingToolbarItem?.itemIdentifier ?? Self.actionsToolbarItemIdentifier
        }

        @available(*, unavailable)
        public required init?(coder _: NSCoder) {
            fatalError()
        }

        override open func loadView() {
            view = NSView()
            view.translatesAutoresizingMaskIntoConstraints = false

            titleLabel.alignment = .center
            titleLabel.font = .systemFont(
                ofSize: NSFont.preferredFont(forTextStyle: .headline).pointSize,
                weight: .semibold
            )
            titleLabel.lineBreakMode = .byTruncatingTail
            titleLabel.maximumNumberOfLines = 1
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 120).isActive = true
            titleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 360).isActive = true

            containerView.translatesAutoresizingMaskIntoConstraints = false
            containerView.wantsLayer = true
            containerView.layer?.masksToBounds = true

            rootScrollView.hasVerticalScroller = true
            rootScrollView.drawsBackground = false
            rootScrollView.translatesAutoresizingMaskIntoConstraints = false
            rootScrollView.automaticallyAdjustsContentInsets = true
            rootDocumentView.translatesAutoresizingMaskIntoConstraints = false

            view.addSubview(rootScrollView)
            rootScrollView.documentView = rootDocumentView
            rootDocumentView.addSubview(containerView)

            NSLayoutConstraint.activate([
                rootScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                rootScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                rootScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                rootScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

                rootDocumentView.topAnchor.constraint(equalTo: rootScrollView.contentView.topAnchor),
                rootDocumentView.leadingAnchor.constraint(equalTo: rootScrollView.contentView.leadingAnchor),
                rootDocumentView.trailingAnchor.constraint(equalTo: rootScrollView.contentView.trailingAnchor),
                rootDocumentView.bottomAnchor.constraint(greaterThanOrEqualTo: rootScrollView.contentView.bottomAnchor),
                rootDocumentView.widthAnchor.constraint(equalTo: rootScrollView.contentView.widthAnchor),
                rootDocumentView.heightAnchor.constraint(greaterThanOrEqualTo: rootScrollView.contentView.heightAnchor),

                containerView.leadingAnchor.constraint(equalTo: rootDocumentView.leadingAnchor),
                containerView.trailingAnchor.constraint(equalTo: rootDocumentView.trailingAnchor),
                containerView.topAnchor.constraint(equalTo: rootDocumentView.topAnchor),
                containerView.bottomAnchor.constraint(equalTo: rootDocumentView.bottomAnchor),
                containerView.heightAnchor.constraint(greaterThanOrEqualTo: rootScrollView.contentView.heightAnchor),
            ])

            transitionToTopController(direction: .none, animated: false)
        }

        override open func viewDidAppear() {
            super.viewDidAppear()
            if let window = view.window {
                configureToolbarIfNeeded(for: window)
            }
            updateNavigationChrome()
            guard escapeEventMonitor == nil else { return }
            escapeEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
                guard let self else { return event }
                guard event.keyCode == 53 else { return event }
                guard event.window === self.view.window else { return event }
                self.requestClose(animated: false)
                return nil
            }
        }

        override open func viewWillDisappear() {
            super.viewWillDisappear()
            if let escapeEventMonitor {
                NSEvent.removeMonitor(escapeEventMonitor)
                self.escapeEventMonitor = nil
            }
        }

        private func configureToolbarIfNeeded(for window: NSWindow) {
            if window.toolbar !== toolbar {
                window.toolbar = toolbar
            }
            if #available(macOS 11.0, *) {
                window.toolbarStyle = .unified
            }
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window.styleMask.insert(.fullSizeContentView)
            window.titlebarSeparatorStyle = .none
        }

        open var canPop: Bool {
            navigationStack.count > 1
        }

        open func isTopController(_ viewController: NSViewController) -> Bool {
            navigationStack.last === viewController
        }

        open func manages(_ viewController: NSViewController) -> Bool {
            if viewController === self { return true }
            return navigationStack.contains(where: { $0 === viewController })
        }

        open func push(_ viewController: NSViewController, animated: Bool = true) {
            navigationStack.append(viewController)
            transitionToTopController(direction: .forward, animated: animated)
        }

        @discardableResult
        open func pop(animated: Bool = true) -> NSViewController? {
            guard canPop else { return nil }
            let popped = navigationStack.removeLast()
            transitionToTopController(direction: .backward, animated: animated)
            return popped
        }

        private func transitionToTopController(direction: NavigationTransitionDirection, animated: Bool) {
            guard let topController = navigationStack.last else { return }
            guard mountedController !== topController else {
                updateNavigationChrome()
                return
            }

            let previousController = mountedController
            addChild(topController)
            let contentView = topController.view
            contentView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(contentView)
            NSLayoutConstraint.activate([
                contentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                contentView.topAnchor.constraint(equalTo: containerView.topAnchor),
                contentView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            ])

            guard let previousController else {
                mountedController = topController
                updateNavigationChrome()
                return
            }

            if animated {
                applyNavigationTransition(direction: direction)
            }

            previousController.view.removeFromSuperview()
            previousController.removeFromParent()
            mountedController = topController
            updateNavigationChrome()
        }

        private func applyNavigationTransition(direction: NavigationTransitionDirection) {
            guard direction != .none else { return }
            guard let transitionSubtype = transitionSubtype(for: direction) else { return }
            let transition = CATransition()
            transition.type = .push
            transition.subtype = transitionSubtype
            transition.duration = 0.25
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            containerView.layer?.add(transition, forKey: "configurable.navigation.transition")
        }

        private func transitionSubtype(for direction: NavigationTransitionDirection) -> CATransitionSubtype? {
            switch direction {
            case .none:
                nil
            case .forward:
                NSApp.userInterfaceLayoutDirection == .leftToRight ? .fromRight : .fromLeft
            case .backward:
                NSApp.userInterfaceLayoutDirection == .leftToRight ? .fromLeft : .fromRight
            }
        }

        open func refreshNavigationChrome() {
            updateNavigationChrome()
        }

        private func updateNavigationChrome() {
            let fallbackTitle = String(localized: controller.manifest.title)
            let currentTitle = navigationStack.last?.title?.trimmingCharacters(in: .whitespacesAndNewlines)
            let resolvedTitle = (currentTitle?.isEmpty == false) ? currentTitle! : fallbackTitle
            titleLabel.stringValue = resolvedTitle

            rebuildTrailingActions()
            view.window?.title = resolvedTitle
        }

        private func rebuildTrailingActions() {
            if trailingToolbarItem != nil {
                return
            }

            trailingActionMenu.removeAllItems()
            guard let topController = navigationStack.last as? NavigationItemMenuProviding else {
                actionsMenuToolbarItem?.isEnabled = false
                return
            }

            let leadingItems = topController.navigationChromeLeadingItems(for: self)
            let trailingItems = topController.navigationChromeTrailingItems(for: self)
            let combined = leadingItems + trailingItems

            for (index, item) in combined.enumerated() {
                trailingActionMenu.addItem(item)
                if index + 1 == leadingItems.count,
                   !leadingItems.isEmpty,
                   !trailingItems.isEmpty
                {
                    trailingActionMenu.addItem(.separator())
                }
            }

            let hasActions = !trailingActionMenu.items.isEmpty
            actionsMenuToolbarItem?.isEnabled = hasActions
        }

        @objc
        private func handleBackButton() {
            _ = pop(animated: true)
        }

        public func toolbarAllowedItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
            [
                Self.backToolbarItemIdentifier,
                Self.titleToolbarItemIdentifier,
                actionsItemIdentifier,
                .space,
                .flexibleSpace,
            ]
        }

        public func toolbarDefaultItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
            [
                Self.backToolbarItemIdentifier,
                .flexibleSpace,
                Self.titleToolbarItemIdentifier,
                .flexibleSpace,
                actionsItemIdentifier,
            ]
        }

        public func toolbar(
            _: NSToolbar,
            itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
            willBeInsertedIntoToolbar _: Bool
        ) -> NSToolbarItem? {
            switch itemIdentifier {
            case Self.backToolbarItemIdentifier:
                let item = NSToolbarItem(itemIdentifier: itemIdentifier)
                let backTitle = String(localized: "Back")
                item.label = backTitle
                item.paletteLabel = backTitle
                item.toolTip = backTitle
                item.target = self
                item.action = #selector(handleBackButton)
                item.isEnabled = false
                item.image = NSImage(systemSymbolName: "chevron.left", accessibilityDescription: nil)
                return item

            case Self.titleToolbarItemIdentifier:
                let item = NSToolbarItem(itemIdentifier: itemIdentifier)
                item.view = titleLabel
                return item

            case let id where id == actionsItemIdentifier:
                let actionsTitle = String(localized: "Actions")

                if let trailingToolbarItem {
                    actionsMenuToolbarItem = nil
                    return trailingToolbarItem
                }

                let item = NSMenuToolbarItem(itemIdentifier: itemIdentifier)
                item.label = actionsTitle
                item.paletteLabel = actionsTitle
                item.toolTip = actionsTitle
                item.image = NSImage(systemSymbolName: "ellipsis.circle", accessibilityDescription: nil)
                item.menu = trailingActionMenu
                item.showsIndicator = false
                actionsMenuToolbarItem = item
                rebuildTrailingActions()
                return item

            default:
                return nil
            }
        }

        private func requestClose(animated: Bool) {
            if let onRequestClose {
                onRequestClose(self)
            } else {
                ckClose(animated: animated)
            }
        }
    }
#endif
