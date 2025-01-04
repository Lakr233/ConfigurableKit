//
//  ViewControllerEmpty.swift
//  ConfigurableExample
//
//  Created by 秋星桥 on 2025/1/4.
//

import ColorfulX
import UIKit

@objc(ViewControllerEmpty)
class ViewControllerEmpty: UIViewController {
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

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        colorful.frame = view.bounds
    }
}
