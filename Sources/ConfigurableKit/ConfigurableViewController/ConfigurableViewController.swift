//
//  ConfigurableViewController.swift
//  ConfigurableView
//
//  Created by 秋星桥 on 2025/1/4.
//

import Combine
import UIKit

open class ConfigurableViewController: StackScrollController {
    let manifest: ConfigurableManifest
    public init(manifest: ConfigurableManifest) {
        self.manifest = manifest
        super.init(nibName: nil, bundle: nil)
        title = manifest.title
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError()
    }

    var cancellables = Set<AnyCancellable>()

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }

    override func setupContentViews() {
        super.setupContentViews()
        stackView.addArrangedSubview(SeparatorView())

        let views = manifest.list.compactMap { $0.createView() }
        for view in views {
            stackView.addArrangedSubviewWithMargin(view)
            stackView.addArrangedSubview(SeparatorView())
        }

        stackView.addArrangedSubviewWithMargin(manifest.footer) { input in
            .init(top: input.top, left: 0, bottom: input.bottom, right: 0)
        }
    }
}
