//
//  ConfigurableView+PageView.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 2025/1/5.
//

import UIKit

public enum ConfigurablePagePresentationStyle {
    case push
    case modal(style: UIModalPresentationStyle = .automatic, embedInNavigationController: Bool = true)
}

open class ConfigurablePageView: ConfigurableActionView {
    let page: () -> (UIViewController?)
    let presentationStyle: ConfigurablePagePresentationStyle

    public init(
        page: @escaping () -> UIViewController?,
        presentationStyle: ConfigurablePagePresentationStyle = .push
    ) {
        self.page = page
        self.presentationStyle = presentationStyle

        super.init(responseEverywhere: true)
        actionBlock = { [weak self] parentViewController in
            guard let self, let page = self.page() else { return }
            page.title = titleLabel.text

            switch presentationStyle {
            case .push:
                parentViewController.navigationController?.pushViewController(page, animated: true)
            case let .modal(style, embedInNavigationController):
                let presentedController: UIViewController
                if embedInNavigationController, page.navigationController == nil {
                    if page.navigationItem.leftBarButtonItem == nil {
                        page.navigationItem.leftBarButtonItem = Self.dismissButton(for: page)
                    }
                    let navigationController = UINavigationController(rootViewController: page)
                    navigationController.modalPresentationStyle = style
                    presentedController = navigationController
                } else {
                    page.modalPresentationStyle = style
                    presentedController = page
                }
                parentViewController.present(presentedController, animated: true)
            }
        }
    }

    override open class func configure(imageView: UIImageView) {
        imageView.image = .init(systemName: "chevron.right", withConfiguration: .largeIcon)?
            .withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .secondaryLabel
    }

    private static func dismissButton(for viewController: UIViewController) -> UIBarButtonItem {
        UIBarButtonItem(
            systemItem: .close,
            primaryAction: UIAction { [weak viewController] _ in
                viewController?.navigationController?.dismiss(animated: true)
                viewController?.dismiss(animated: true)
            }
        )
    }
}
