//
//  ConfigurableView+PageView.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 2025/1/5.
//

import UIKit

open class ConfigurablePageView: ConfigurableActionView {
    let page: () -> (UIViewController?)

    public init(page: @escaping () -> UIViewController?) {
        self.page = page

        super.init(responseEverywhere: true)
        actionBlock = { [weak self] parentViewController in
            guard let page = self?.page() else { return }
            page.title = self?.titleLabel.text
            parentViewController?.navigationController?.pushViewController(page, animated: true)
        }
    }

    override class func configure(imageView: UIImageView) {
        imageView.image = .init(systemName: "chevron.right", withConfiguration: .largeIcon)?
            .withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .secondaryLabel
    }
}
