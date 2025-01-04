//
//  ViewController.swift
//  ConfigurableExample
//
//  Created by 秋星桥 on 2025/1/4.
//

import ConfigurableKit
import UIKit

let shareFile = Bundle.main.url(forResource: "File", withExtension: "png")!

class ViewController: UIViewController {
    let configurableValues: [ConfigurableObject] = [
        ConfigurableObject(
            icon: "number",
            title: "Value Objects",
            explain: "List of value objects that actually stores item",
            ephemeralAnnotation: .submenu { [
                ConfigurableObject(
                    icon: "plus",
                    title: "Self Increase Button",
                    explain: "Demo about AnnotationProtocol",
                    key: "wiki.qaq.demo.self.increase",
                    defaultValue: 233,
                    annotation: SelfIncreaseNumberAnnotation()
                )
                .whenValueChange(type: Int.self) { print("Value Changed to \($0 ?? -1)") },
                ConfigurableObject(
                    icon: "plus",
                    title: "Self Increase Button!!",
                    explain: "Demo about AnnotationProtocol, value reset randomly to 0",
                    key: "wiki.qaq.demo.self.increase",
                    defaultValue: 233,
                    annotation: SelfIncreaseNumberAnnotation()
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
                    annotation: .boolean
                ),
                ConfigurableObject(
                    icon: "switch.2",
                    title: "Relatively Inaccessible Item",
                    explain: "Requires above item to be true to be edited",
                    key: "wiki.qaq.test.boolean.inaccessible.0",
                    defaultValue: true,
                    annotation: .boolean,
                    availabilityRequirement: .init(key: "wiki.qaq.test.boolean")
                ),
                ConfigurableObject(
                    icon: "switch.2",
                    title: "Relatively Inaccessible Item",
                    explain: "Requires above item to be false to be edited",
                    key: "wiki.qaq.test.boolean.inaccessible.1",
                    defaultValue: true,
                    annotation: .boolean,
                    availabilityRequirement: .init(key: "wiki.qaq.test.boolean", reversed: true)
                ),
                ConfigurableObject(
                    icon: "contextualmenu.and.cursorarrow",
                    title: "Menu",
                    explain: "Choose value from a predefined list",
                    key: "wiki.qaq.test.menu",
                    defaultValue: "A",
                    annotation: .list(selections: [
                        .init(icon: "1.circle", title: "Select Value 1", section: "Number Values", rawValue: "1"),
                        .init(icon: "2.circle", title: "Select Value 2", section: "Number Values", rawValue: "2"),
                        .init(icon: "3.circle", title: "Select Value 3", section: "Number Values", rawValue: "3"),
                        .init(icon: "a.circle", title: "Select Value A", section: "Text Values", rawValue: "A"),
                        .init(icon: "b.circle", title: "Select Value B", section: "Text Values", rawValue: "B"),
                        .init(icon: "c.circle", title: "Select Value C", section: "Text Values", rawValue: "C"),
                    ])
                ),
                ConfigurableObject(
                    icon: "switch.2",
                    title: "Relatively Inaccessible Item",
                    explain: "Requires above item to be value A to be edited",
                    key: "wiki.qaq.test.boolean.inaccessible.2",
                    defaultValue: true,
                    annotation: .boolean,
                    availabilityRequirement: .init(key: "wiki.qaq.test.menu", match: "A")
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
                        let alert = UIAlertController(
                            title: "Hello",
                            message: "This is an alert",
                            preferredStyle: .alert
                        )
                        alert.addAction(.init(title: "OK", style: .default))
                        viewController?.present(alert, animated: true)
                    }
                ),
                ConfigurableObject(
                    icon: "link",
                    title: "Informative Link",
                    explain: "Open a link, calls openURL under the hood",
                    ephemeralAnnotation: .openLink(title: "example.com", url: URL(string: "https://example.com")!)
                ),
                ConfigurableObject(
                    icon: "arrow.right",
                    title: "Custom Page",
                    explain: "Open a custom defined view controller with push",
                    ephemeralAnnotation: .page { ViewControllerEmpty() }
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
                                    annotation: .boolean
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
                    ephemeralAnnotation: .quickLook(title: "Quick Look", url: shareFile)
                ),
                ConfigurableObject(
                    icon: "arrow.right",
                    title: "Share Link",
                    explain: "Open system share sheet with the file",
                    ephemeralAnnotation: .shareLink(title: "Share File", url: shareFile)
                ),
            ] }
        ),
        ConfigurableObject {
            let label = UILabel()
            label.text = "Press Esc to Close"
            label.font = .preferredFont(forTextStyle: .footnote)
            label.textAlignment = .center
            label.alpha = 0.5
            return label
        },
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
                    annotation: .boolean
                ),
                ConfigurableObject(
                    icon: "2.circle",
                    title: "Editor B",
                    explain: "This value is synchronized with Editor A",
                    key: "wiki.qaq.demo.sync.toggle",
                    defaultValue: true,
                    annotation: .boolean
                ),
                ConfigurableObject(
                    icon: "a.circle",
                    title: "Text List A",
                    explain: "This value is synchronized with Text List B",
                    key: "wiki.qaq.demo.sync.text.2",
                    defaultValue: "Happy",
                    annotation: .list(selections: [
                        .init(title: "Happy", rawValue: "Happy"),
                        .init(title: "Sad", rawValue: "Sad"),
                        .init(title: "Angry", rawValue: "Angry"),
                        .init(title: "Excited", rawValue: "Excited"),
                        .init(title: "Surprised", rawValue: "Surprised"),
                        .init(title: "Confused", rawValue: "Confused"),
                    ])
                ),
                ConfigurableObject(
                    icon: "b.circle",
                    title: "Text List B",
                    explain: "This value is synchronized with Text List A",
                    key: "wiki.qaq.demo.sync.text.2",
                    defaultValue: "Happy",
                    annotation: .list(selections: [
                        .init(title: "Happy", rawValue: "Happy"),
                        .init(title: "Sad", rawValue: "Sad"),
                        .init(title: "Angry", rawValue: "Angry"),
                        .init(title: "Excited", rawValue: "Excited"),
                        .init(title: "Surprised", rawValue: "Surprised"),
                        .init(title: "Confused", rawValue: "Confused"),
                    ])
                ),
            ] }
        ),
    ]

    let button = UIButton(type: .system)
    lazy var settingController = ConfigurableSheetController(manifest: .init(
        title: "Settings",
        list: configurableValues,
        footer: "Made with Love by Own Goal Studio"
    ))

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(button)
        button.setTitle("Open Setting Page", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(open), for: .touchUpInside)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        button.frame = CGRect(x: 0, y: 0, width: 256, height: 64)
        button.center = view.center
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        open()
    }

    @objc func open() {
        settingController.title = "Settings"
        present(settingController, animated: true)
    }
}
