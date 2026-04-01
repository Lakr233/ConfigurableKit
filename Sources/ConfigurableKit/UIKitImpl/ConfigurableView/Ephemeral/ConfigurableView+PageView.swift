#if canImport(UIKit)
//
    //  ConfigurableView+PageView.swift
    //  ConfigurableKit
//
    //  Created by 秋星桥 on 2025/1/5.
//

    import UIKit

    public enum ConfigurablePagePresentationStyle {
        case push
        case modal(style: CKModalPresentationStyle = .automatic, embedInNavigationController: Bool = true)
    }

    open class ConfigurablePageView: ConfigurableActionView {
        let page: () -> (CKViewController?)
        let presentationStyle: ConfigurablePagePresentationStyle

        public init(
            page: @escaping () -> CKViewController?,
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
                    parentViewController.ckPush(page, animated: true)
                case let .modal(style, embedInNavigationController):
                    let presentedController = modalPresenter(
                        for: page,
                        embedInNavigationController: embedInNavigationController
                    )
                    parentViewController.ckPresentModal(presentedController, style: style, animated: true)
                }
            }
        }

        override open class func configure(imageView: UIImageView) {
            imageView.image = .init(systemName: "chevron.right", withConfiguration: .largeIcon)?
                .withRenderingMode(.alwaysTemplate)
            imageView.tintColor = .secondaryLabel
        }

        private func modalPresenter(
            for page: CKViewController,
            embedInNavigationController: Bool
        ) -> CKViewController {
            if embedInNavigationController, page.navigationController == nil {
                if page.navigationItem.leftBarButtonItem == nil {
                    page.navigationItem.leftBarButtonItem = Self.dismissButton(for: page)
                }
                return UINavigationController(rootViewController: page)
            }
            return page
        }

        private static func dismissButton(for viewController: CKViewController) -> UIBarButtonItem {
            UIBarButtonItem(
                systemItem: .close,
                primaryAction: UIAction { [weak viewController] _ in
                    viewController?.ckClose(animated: true)
                }
            )
        }
    }
#endif
