#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    import AppKit
    import Combine
    import ConfigurableKit

    let demoStorage = UserDefaultKeyValueStorage(suite: .standard)

    private enum DemoInterfaceStyle: String {
        case system
        case light
        case dark

        var appearance: NSAppearance? {
            switch self {
            case .system:
                nil
            case .light:
                NSAppearance(named: .aqua)
            case .dark:
                NSAppearance(named: .darkAqua)
            }
        }
    }

    private func demoShareFileURL() -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("ConfigurableKit-Demo-Share.txt")
        if !FileManager.default.fileExists(atPath: url.path) {
            let content = "ConfigurableKit demo share file."
            try? content.write(to: url, atomically: true, encoding: .utf8)
        }
        return url
    }

    // MARK: - Custom Annotation Demo

    final class SelfIncreaseNumberAnnotation: ConfigurableObject.AnnotationProtocol {
        @MainActor
        func createView(fromObject object: ConfigurableObject) -> ConfigurableView {
            SelfIncreaseNumberConfigurableView(storage: object.valueStorage)
        }
    }

    final class SelfIncreaseNumberConfigurableView: ConfigurableStorableView {
        private var button: NSButton {
            contentView as! NSButton
        }

        private var intValue: Int {
            get { value.decodingValue(defaultValue: 0) }
            set { value = .init(newValue) }
        }

        override init(storage: CodableStorage) {
            super.init(storage: storage)

            button.target = self
            button.action = #selector(tapped)
            button.isBordered = false
            button.alignment = .right
            button.font = .systemFont(
                ofSize: NSFont.preferredFont(forTextStyle: .subheadline).pointSize,
                weight: .semibold
            )
        }

        override class func createContentView() -> NSView {
            let button = NSButton(title: "", target: nil, action: nil)
            button.isBordered = false
            button.alignment = .right
            return button
        }

        override func updateValue() {
            super.updateValue()
            let title = "\(intValue)"
            button.attributedTitle = NSAttributedString(string: title, attributes: [
                .foregroundColor: NSColor.controlAccentColor,
                .font: NSFont.systemFont(
                    ofSize: NSFont.preferredFont(forTextStyle: .subheadline).pointSize,
                    weight: .semibold
                ),
            ])
        }

        @objc
        private func tapped() {
            intValue += 1
        }
    }

    // MARK: - ObjectList Demo

    struct User: ObjectListFormItem {
        let id: UUID
        var name: String
        var email: String
        var role: String
        var isActive: Bool

        func matches(query: String) -> Bool {
            name.localizedCaseInsensitiveContains(query)
                || email.localizedCaseInsensitiveContains(query)
                || role.localizedCaseInsensitiveContains(query)
        }

        static func createDefault() -> User {
            User(id: UUID(), name: "", email: "", role: "viewer", isActive: true)
        }

        static var formFields: [ObjectListField<User>] {
            [
                .text(
                    id: "name",
                    title: "Name",
                    icon: "person",
                    keyPath: \.name,
                    placeholder: "Enter name"
                ),
                .text(
                    id: "email",
                    title: "Email",
                    icon: "envelope",
                    keyPath: \.email,
                    placeholder: "user@example.com"
                ),
                .picker(
                    id: "role",
                    title: "Role",
                    icon: "person.badge.key",
                    keyPath: \.role,
                    options: [
                        (title: "Admin", icon: "shield", value: "admin"),
                        (title: "Editor", icon: "pencil", value: "editor"),
                        (title: "Viewer", icon: "eye", value: "viewer"),
                    ]
                ),
                .toggle(
                    id: "active",
                    title: "Active",
                    icon: "checkmark.circle",
                    keyPath: \.isActive
                ),
                .display(
                    id: "id",
                    title: "User ID",
                    icon: "number",
                    keyPath: \.id,
                    formatter: { $0.uuidString.prefix(8).uppercased() + "..." }
                ),
            ]
        }
    }

    @MainActor
    final class UserDataSource: ObjectListFormDataSource<User> {
        override var sortCriteria: [ObjectListSortCriterion<User>] {
            [
                ObjectListSortCriterion(
                    id: "name",
                    title: "Name",
                    icon: "textformat.abc"
                ) { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending },
                ObjectListSortCriterion(
                    id: "role",
                    title: "Role",
                    icon: "person.badge.key"
                ) { $0.role < $1.role },
            ]
        }
    }

    @MainActor
    private func makeDemoUserDataSource() -> UserDataSource {
        UserDataSource(items: [
            User(id: UUID(), name: "Alice Chen", email: "alice@example.com", role: "admin", isActive: true),
            User(id: UUID(), name: "Bob Smith", email: "bob@example.com", role: "editor", isActive: true),
            User(id: UUID(), name: "Charlie Davis", email: "charlie@example.com", role: "viewer", isActive: false),
            User(id: UUID(), name: "Diana Park", email: "diana@example.com", role: "editor", isActive: true),
        ])
    }

    // MARK: - Custom Page Demo

    final class CustomSeparator: NSView, ConfigurableSeparatorProtocol {
        static let defaultHeight: CGFloat = 2.0

        override init(frame: CGRect) {
            super.init(frame: frame)
            wantsLayer = true
            layer?.backgroundColor = NSColor.systemBlue.withAlphaComponent(0.3).cgColor
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError()
        }
    }

    final class GradientSeparator: NSView, ConfigurableSeparatorProtocol {
        static let defaultHeight: CGFloat = 1.0

        private let gradientLayer = CAGradientLayer()

        override init(frame: CGRect) {
            super.init(frame: frame)
            wantsLayer = true
            setupGradient()
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError()
        }

        private func setupGradient() {
            gradientLayer.colors = [
                NSColor.clear.cgColor,
                NSColor.systemGray.withAlphaComponent(0.3).cgColor,
                NSColor.clear.cgColor,
            ]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
            layer?.addSublayer(gradientLayer)
        }

        override func layout() {
            super.layout()
            gradientLayer.frame = bounds
        }
    }

    final class AnimatedGradientBackgroundView: NSView {
        private let gradientLayer = CAGradientLayer()

        override init(frame: CGRect) {
            super.init(frame: frame)
            wantsLayer = true
            layer = CALayer()
            setupGradient()
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError()
        }

        private func setupGradient() {
            let fromColors: [CGColor] = [
                NSColor.systemBlue.withAlphaComponent(0.28).cgColor,
                NSColor.systemPurple.withAlphaComponent(0.24).cgColor,
                NSColor.systemTeal.withAlphaComponent(0.22).cgColor,
            ]
            let toColors: [CGColor] = [
                NSColor.systemPink.withAlphaComponent(0.26).cgColor,
                NSColor.systemIndigo.withAlphaComponent(0.24).cgColor,
                NSColor.systemMint.withAlphaComponent(0.22).cgColor,
            ]

            gradientLayer.colors = fromColors
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
            layer?.addSublayer(gradientLayer)

            let animation = CABasicAnimation(keyPath: "colors")
            animation.fromValue = fromColors
            animation.toValue = toColors
            animation.duration = 8
            animation.autoreverses = true
            animation.repeatCount = .infinity
            gradientLayer.add(animation, forKey: "colorShift")
        }

        override func layout() {
            super.layout()
            gradientLayer.frame = bounds
        }
    }

    @MainActor
    final class DemoPageViewController: StackScrollController {
        private let colorfulBackground = AnimatedGradientBackgroundView()

        override func viewDidLoad() {
            super.viewDidLoad()
            title = "Custom Page"

            colorfulBackground.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(colorfulBackground, positioned: .below, relativeTo: contentView)
            NSLayoutConstraint.activate([
                colorfulBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                colorfulBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                colorfulBackground.topAnchor.constraint(equalTo: view.topAnchor),
                colorfulBackground.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])

            view.layer?.backgroundColor = NSColor.clear.cgColor
            contentView.wantsLayer = true
            contentView.layer?.backgroundColor = NSColor.clear.cgColor
        }

        override func setupContentViews() {
            super.setupContentViews()

            let header = ConfigurableSectionHeaderView().with(header: "Hello World")
            stackView.addArrangedSubviewWithMargin(header) { margin in
                margin.bottom /= 2
            }
            stackView.addArrangedSubview(GradientSeparator())

            let demo = ConfigurableActionView()
            demo.configure(icon: .image(optionalName: "star.fill"))
            demo.configure(title: "Demo")
            demo.configure(description: "Duis magna sit consectetur enim aute. Consectetur nulla sint id nulla aliqua et id anim irure laborum. Dolor amet enim sint elit exercitation irure minim in qui sunt laboris eiusmod dolor. Velit officia voluptate voluptate minim veniam pariatur dolore sit consectetur dolor aliquip. Deserunt aliquip ea consectetur labore ut aliqua id do cillum enim nulla. Cillum irure enim ipsum dolor duis id culpa amet Lorem. Fugiat sint nostrud aliquip enim ipsum velit elit officia irure enim enim occaecat. Sint veniam id ea ut quis Lorem cillum laborum.")
            stackView.addArrangedSubviewWithMargin(demo)
            stackView.addArrangedSubview(CustomSeparator())

            let footer = ConfigurableSectionFooterView().with(footer: "Duis magna sit consectetur enim aute. Consectetur nulla sint id nulla aliqua et id anim irure laborum. Dolor amet enim sint elit exercitation irure minim in qui sunt laboris eiusmod dolor. Velit officia voluptate voluptate minim veniam pariatur dolore sit consectetur dolor aliquip. Deserunt aliquip ea consectetur labore ut aliqua id do cillum enim nulla. Cillum irure enim ipsum dolor duis id culpa amet Lorem. Fugiat sint nostrud aliquip enim ipsum velit elit officia irure enim enim occaecat. Sint veniam id ea ut quis Lorem cillum laborum.")
            stackView.addArrangedSubviewWithMargin(footer) { margin in
                margin.top /= 2
            }
        }
    }

    @MainActor
    private func buildConfigurableValues() -> [ConfigurableObject] {
        let demoShareFile = demoShareFileURL()
        let demoUserDataSource = makeDemoUserDataSource()

        return [
            ConfigurableObject(
                icon: "number",
                title: "Value Objects",
                explain: "List of value objects that actually stores item",
                ephemeralAnnotation: .submenu { [
                    ConfigurableObject(
                        icon: "moon",
                        title: String.LocalizationValue("Color Theme"),
                        explain: String.LocalizationValue("Select the color theme."),
                        key: "theme",
                        defaultValue: "system",
                        annotation: .menu { [
                            .init(
                                icon: "circle.righthalf.fill",
                                title: String.LocalizationValue("System"),
                                section: String.LocalizationValue("System"),
                                rawValue: "system"
                            ),
                            .init(
                                icon: "sun.min",
                                title: String.LocalizationValue("Light"),
                                section: String.LocalizationValue("Override"),
                                rawValue: "light"
                            ),
                            .init(
                                icon: "moon",
                                title: String.LocalizationValue("Dark"),
                                section: String.LocalizationValue("Override"),
                                rawValue: "dark"
                            ),
                        ] },
                        storage: demoStorage
                    ),
                    ConfigurableObject(
                        icon: "plus",
                        title: "Self Increase Button",
                        explain: "Demo about AnnotationProtocol, synced below",
                        key: "wiki.qaq.demo.self.increase",
                        defaultValue: 233,
                        annotation: SelfIncreaseNumberAnnotation(),
                        storage: demoStorage
                    )
                    .whenValueChange(type: Int.self) { print("Value Changed to \($0 ?? -1)") },
                    ConfigurableObject(
                        icon: "plus",
                        title: "Self Increase Button!!",
                        explain: "Demo about AnnotationProtocol, value reset randomly to 0",
                        key: "wiki.qaq.demo.self.increase",
                        defaultValue: 233,
                        annotation: SelfIncreaseNumberAnnotation(),
                        storage: demoStorage
                    )
                    .whenValueChange(type: Int.self) {
                        if [0, 1, 2, 3, 4, 5, 6].shuffled().first == 0 { return 0 }
                        return $0
                    },
                    ConfigurableObject(
                        icon: "switch.2",
                        title: "Toggle Item Below",
                        explain: "Item with boolean value to be edited",
                        key: "wiki.qaq.test.boolean",
                        defaultValue: true,
                        annotation: .toggle,
                        storage: demoStorage
                    ),
                    ConfigurableObject(
                        icon: "switch.2",
                        title: "Relatively Inaccessible Item",
                        explain: "Requires above item to be true to be edited",
                        key: "wiki.qaq.test.boolean.inaccessible.0",
                        defaultValue: true,
                        annotation: .toggle,
                        availabilityRequirement: .match(key: "wiki.qaq.test.boolean"),
                        storage: demoStorage
                    ),
                    ConfigurableObject(
                        icon: "switch.2",
                        title: "Relatively Inaccessible Item",
                        explain: "Requires above item to be false to be edited",
                        key: "wiki.qaq.test.boolean.inaccessible.1",
                        defaultValue: true,
                        annotation: .toggle,
                        availabilityRequirement: .negatedMatch(key: "wiki.qaq.test.boolean.inaccessible.0"),
                        storage: demoStorage
                    ),
                    ConfigurableObject(
                        icon: "contextualmenu.and.cursorarrow",
                        title: "Menu",
                        explain: "Choose value from a predefined list",
                        key: "wiki.qaq.test.menu",
                        defaultValue: "A",
                        annotation: .menu { [
                            .init(icon: "1.circle", title: "Select Value 1", section: "Number Values", rawValue: "1"),
                            .init(icon: "2.circle", title: "Select Value 2", section: "Number Values", rawValue: "2"),
                            .init(icon: "3.circle", title: "Select Value 3", section: "Number Values", rawValue: "3"),
                            .init(icon: "a.circle", title: "Select Value A", section: "Text Values", rawValue: "A"),
                            .init(icon: "b.circle", title: "Select Value B", section: "Text Values", rawValue: "B"),
                            .init(icon: "c.circle", title: "Select Value C", section: "Text Values", rawValue: "C"),
                        ] },
                        storage: demoStorage
                    ),
                    ConfigurableObject(
                        icon: "switch.2",
                        title: "Relatively Inaccessible Item",
                        explain: "Requires above item to be value A to be edited",
                        key: "wiki.qaq.test.boolean.inaccessible.2",
                        defaultValue: true,
                        annotation: .toggle,
                        availabilityRequirement: .match(key: "wiki.qaq.test.menu", value: "A"),
                        storage: demoStorage
                    ),
                ] }
            ),
            ConfigurableObject(
                icon: "pencil.slash",
                title: "Ephemeral Objects",
                explain: "List of objects that does something other then storing values",
                ephemeralAnnotation: .submenu { [
                    ConfigurableObject(
                        icon: "trash",
                        title: "Do Something",
                        explain: "Register a block to be executed",
                        ephemeralAnnotation: .action { viewController in
                            let alert = NSAlert()
                            alert.messageText = "Hello"
                            alert.informativeText = "This is an alert"
                            alert.addButton(withTitle: "OK")
                            if let window = viewController.view.window {
                                alert.beginSheetModal(for: window) { _ in }
                            } else {
                                alert.runModal()
                            }
                        }
                    ),
                    ConfigurableObject(
                        icon: "link",
                        title: "Informative Link",
                        explain: "Open a link, calls openURL under the hood",
                        ephemeralAnnotation: .link(title: "example.com", url: URL(string: "https://example.com")!)
                    ),
                    ConfigurableObject(
                        icon: "arrow.right",
                        title: "Custom Page",
                        explain: "Open a custom defined view controller with push",
                        ephemeralAnnotation: .page { DemoPageViewController() }
                    ),
                    ConfigurableObject(
                        icon: "sun.min",
                        title: "Deferred Submenu",
                        explain: "Show you some random item when tap to open",
                        ephemeralAnnotation: .submenu {
                            var ans = [ConfigurableObject]()
                            for i in 0 ..< Int.random(in: 4 ... 8) {
                                ans.append(
                                    ConfigurableObject(
                                        icon: "number",
                                        title: "Item \(i)",
                                        explain: "This is \(i)(th) item",
                                        key: "wiki.qaq.test.boolean.\(i)",
                                        defaultValue: true,
                                        annotation: .toggle,
                                        storage: demoStorage
                                    )
                                )
                            }
                            return ans
                        }
                    ),
                ] }
            ),
            ConfigurableObject(
                icon: "square.and.arrow.up",
                title: "Share Objects",
                explain: "Preview item at url or share it with system share sheet",
                ephemeralAnnotation: .submenu { [
                    ConfigurableObject(
                        icon: "arrow.right",
                        title: "Quick Look",
                        explain: "Open a quick look preview for the file",
                        ephemeralAnnotation: .quickLook(title: "Quick Look", url: demoShareFile)
                    ),
                    ConfigurableObject(
                        icon: "arrow.right",
                        title: "Share Link",
                        explain: "Open system share sheet with the file",
                        ephemeralAnnotation: .share(title: "Share File", url: demoShareFile)
                    ),
                ] }
            ),
            ConfigurableObject(
                icon: "person.2",
                title: "User Management",
                explain: "ObjectListFormItem demo with search, sort, CRUD, drag-drop",
                ephemeralAnnotation: ObjectListAnnotation(
                    dataSource: demoUserDataSource,
                    presentationStyle: .push
                )
            ),
            ConfigurableObject(customView: {
                let label = NSTextField(labelWithString: "Press Esc to Close")
                label.alignment = .center
                label.textColor = .secondaryLabelColor
                return label
            }),
            ConfigurableObject(
                icon: "hare",
                title: "Synchronized Values",
                explain: "Demo for synchronized values cross multiple views",
                ephemeralAnnotation: .submenu { [
                    ConfigurableObject(
                        icon: "1.circle",
                        title: "Editor A",
                        explain: "This value is synchronized with Editor B",
                        key: "wiki.qaq.demo.sync.toggle",
                        defaultValue: true,
                        annotation: .toggle,
                        storage: demoStorage
                    ),
                    ConfigurableObject(
                        icon: "2.circle",
                        title: "Editor B",
                        explain: "This value is synchronized with Editor A",
                        key: "wiki.qaq.demo.sync.toggle",
                        defaultValue: true,
                        annotation: .toggle,
                        storage: demoStorage
                    ),
                    ConfigurableObject(
                        icon: "a.circle",
                        title: "Text List A",
                        explain: "This value is synchronized with Text List B",
                        key: "wiki.qaq.demo.sync.text.2",
                        defaultValue: "Happy",
                        annotation: .menu { [
                            .init(title: "Happy", rawValue: "Happy"),
                            .init(title: "Sad", rawValue: "Sad"),
                            .init(title: "Angry", rawValue: "Angry"),
                            .init(title: "Excited", rawValue: "Excited"),
                            .init(title: "Surprised", rawValue: "Surprised"),
                            .init(title: "Confused", rawValue: "Confused"),
                        ] },
                        storage: demoStorage
                    ),
                    ConfigurableObject(
                        icon: "b.circle",
                        title: "Text List B",
                        explain: "This value is synchronized with Text List A",
                        key: "wiki.qaq.demo.sync.text.2",
                        defaultValue: "Happy",
                        annotation: .menu { [
                            .init(title: "Happy", rawValue: "Happy"),
                            .init(title: "Sad", rawValue: "Sad"),
                            .init(title: "Angry", rawValue: "Angry"),
                            .init(title: "Excited", rawValue: "Excited"),
                            .init(title: "Surprised", rawValue: "Surprised"),
                            .init(title: "Confused", rawValue: "Confused"),
                        ] },
                        storage: demoStorage
                    ),
                ] }
            ),
        ]
    }

    @MainActor
    private func buildDemoManifest() -> ConfigurableManifest {
        ConfigurableManifest(
            title: "Settings",
            list: buildConfigurableValues(),
            footer: "Made with Love by Own Goal Studio"
        )
    }

    @MainActor
    final class DemoRootViewController: NSViewController {
        private static let trailingToolbarItemIdentifier = NSToolbarItem.Identifier(
            "ConfigurableMacDemo.trailingActions"
        )

        private lazy var trailingToolbarMenu: NSMenu = {
            let menu = NSMenu()
            let closeItem = NSMenuItem(
                title: String(localized: "Close"),
                action: #selector(closeFromToolbarMenu),
                keyEquivalent: ""
            )
            closeItem.target = self
            menu.addItem(closeItem)
            return menu
        }()

        private lazy var trailingToolbarItem: NSMenuToolbarItem = {
            let title = String(localized: "Actions")
            let item = NSMenuToolbarItem(itemIdentifier: Self.trailingToolbarItemIdentifier)
            item.label = title
            item.paletteLabel = title
            item.toolTip = title
            item.image = NSImage(systemSymbolName: "ellipsis.circle", accessibilityDescription: nil)
            item.showsIndicator = false
            item.menu = trailingToolbarMenu
            return item
        }()

        private lazy var settingController: ConfigurableSheetController = {
            let controller = ConfigurableSheetController(
                manifest: buildDemoManifest(),
                trailingToolbarItem: trailingToolbarItem
            )
            controller.onRequestClose = { [weak self] _ in
                self?.view.window?.close()
            }
            return controller
        }()

        @objc
        private func closeFromToolbarMenu() {
            settingController.ckClose(animated: true)
        }

        override func loadView() {
            view = NSView()
        }

        override func viewDidLoad() {
            super.viewDidLoad()

            view.wantsLayer = true
            view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
            mountSettingsIfNeeded()
        }

        override func viewDidAppear() {
            super.viewDidAppear()
            settingController.title = "Settings"
        }

        private func mountSettingsIfNeeded() {
            guard settingController.parent == nil else { return }
            addChild(settingController)
            let contentView = settingController.view
            contentView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(contentView)
            NSLayoutConstraint.activate([
                contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                contentView.topAnchor.constraint(equalTo: view.topAnchor),
                contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
        }
    }

    @MainActor
    final class DemoAppDelegate: NSObject, NSApplicationDelegate {
        private var window: NSWindow?
        private var cancellables = Set<AnyCancellable>()

        func applicationDidFinishLaunching(_: Notification) {
            ConfigurableKit.storage = demoStorage

            let controller = DemoRootViewController()
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 1024, height: 768),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            window.title = "ConfigurableMacDemo"
            window.center()
            window.contentViewController = controller
            window.makeKeyAndOrderFront(nil)
            self.window = window

            ConfigurableKit.publisher(forKey: "theme", type: String.self)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] value in
                    guard let self,
                          let value,
                          let style = DemoInterfaceStyle(rawValue: value)
                    else { return }
                    NSApp.appearance = style.appearance
                    self.window?.appearance = style.appearance
                }
                .store(in: &cancellables)
        }

        func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
            true
        }
    }

    @MainActor
    private func runDemoApp() {
        let app = NSApplication.shared
        let delegate = DemoAppDelegate()
        app.setActivationPolicy(.regular)
        app.delegate = delegate
        app.activate(ignoringOtherApps: true)
        app.run()
    }

    runDemoApp()
#endif
