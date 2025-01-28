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
            margin.bottom = 0
        }
        let demo = ConfigurableActionView()
        demo.configure(icon: .image(optionalName: "star.fill"))
        demo.configure(title: "Demo")
        demo.configure(description: "This is a demo view")
        stackView.addArrangedSubview(SeparatorView())
        stackView.addArrangedSubviewWithMargin(demo)
        stackView.addArrangedSubview(SeparatorView())
    }
}
