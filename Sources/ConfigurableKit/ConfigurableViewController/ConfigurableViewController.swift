//
//  ConfigurableViewController.swift
//  ConfigurableView
//
//  Created by 秋星桥 on 2025/1/4.
//

import Combine
import UIKit

open class ConfigurableViewController: StackScrollController {
    public let manifest: ConfigurableManifest
    public init(manifest: ConfigurableManifest) {
        self.manifest = manifest
        super.init(nibName: nil, bundle: nil)
        title = String(localized: manifest.title)
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError()
    }

    public var cancellables = Set<AnyCancellable>()

    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }

    override open func setupContentViews() {
        super.setupContentViews()
        stackView.addArrangedSubview(SeparatorView())

        let views = manifest.list.compactMap { $0.createView() }
        for view in views {
            stackView.addArrangedSubviewWithMargin(view)
            stackView.addArrangedSubview(SeparatorView())
        }

        stackView.addArrangedSubviewWithMargin(manifest.footer) { input in
            input.left = 0
            input.right = 0
        }
    }
}
