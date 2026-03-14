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

    public weak var delegate: ConfigurableViewControllerDelegate?

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
    public var onDeinit: (@Sendable () -> Void)?

    deinit {
        onDeinit?()
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        var leadingItems: [UIBarButtonItem] = []
        var trailingItems: [UIBarButtonItem] = []
        var toolItems: [UIBarButtonItem] = []

        delegate?.configurableViewController(self, configureLeadingBarButtonItems: &leadingItems)
        delegate?.configurableViewController(self, configureTrailingBarButtonItems: &trailingItems)
        delegate?.configurableViewController(self, configureToolbarItems: &toolItems)

        if !leadingItems.isEmpty {
            navigationItem.leftBarButtonItems = leadingItems
        }
        if !trailingItems.isEmpty {
            navigationItem.rightBarButtonItems = trailingItems
        }
        if !toolItems.isEmpty {
            toolbarItems = toolItems
            navigationController?.setToolbarHidden(false, animated: false)
        }

        delegate?.configurableViewControllerDidLoad(self)
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.configurableViewControllerWillAppear(self)
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.configurableViewControllerDidAppear(self)
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
