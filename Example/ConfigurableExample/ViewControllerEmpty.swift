//
//  ViewControllerEmpty.swift
//  ConfigurableExample
//
//  Created by 秋星桥 on 2025/1/4.
//

import ColorfulX
import ConfigurableKit
import UIKit

@objc(ViewControllerEmpty)
class ViewControllerEmpty: StackScrollController {
    let colorful = AnimatedMulticolorGradientView()

    init() {
        super.init(nibName: nil, bundle: nil)
        title = "Custom Page"
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        colorful.setColors(ColorfulPreset.appleIntelligence.colors)
        colorful.speed = 0.5
        view.addSubview(colorful)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        view.sendSubviewToBack(colorful)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        colorful.frame = view.bounds
    }

    override func setupContentViews() {
        super.setupContentViews()

        let header = ConfigurableSectionHeaderView().with(header: "Hello World")
        stackView.addArrangedSubviewWithMargin(header) { margin in
            margin.bottom /= 2
        }
        let demo = ConfigurableActionView()
        demo.configure(icon: .image(optionalName: "star.fill"))
        demo.configure(title: "Demo")
        demo.configure(description: "Duis magna sit consectetur enim aute. Consectetur nulla sint id nulla aliqua et id anim irure laborum. Dolor amet enim sint elit exercitation irure minim in qui sunt laboris eiusmod dolor. Velit officia voluptate voluptate minim veniam pariatur dolore sit consectetur dolor aliquip. Deserunt aliquip ea consectetur labore ut aliqua id do cillum enim nulla. Cillum irure enim ipsum dolor duis id culpa amet Lorem. Fugiat sint nostrud aliquip enim ipsum velit elit officia irure enim enim occaecat. Sint veniam id ea ut quis Lorem cillum laborum.")
        stackView.addArrangedSubview(SeparatorView())
        stackView.addArrangedSubviewWithMargin(demo)
        stackView.addArrangedSubview(SeparatorView())
        let footer = ConfigurableSectionFooterView().with(footer: "Duis magna sit consectetur enim aute. Consectetur nulla sint id nulla aliqua et id anim irure laborum. Dolor amet enim sint elit exercitation irure minim in qui sunt laboris eiusmod dolor. Velit officia voluptate voluptate minim veniam pariatur dolore sit consectetur dolor aliquip. Deserunt aliquip ea consectetur labore ut aliqua id do cillum enim nulla. Cillum irure enim ipsum dolor duis id culpa amet Lorem. Fugiat sint nostrud aliquip enim ipsum velit elit officia irure enim enim occaecat. Sint veniam id ea ut quis Lorem cillum laborum.")
        stackView.addArrangedSubviewWithMargin(footer) { margin in
            margin.top /= 2
        }
    }
}
