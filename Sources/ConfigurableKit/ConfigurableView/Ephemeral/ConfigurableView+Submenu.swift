//
//  ConfigurableView+Submenu.swift
//  TRApp
//
//  Created by 82Flex on 2024/9/14.
//

import Combine
import UIKit

open class ConfigurableSubmenuView: ConfigurableActionView {
    let childrenReader: () -> [ConfigurableObject]

    init(childrenReader: @escaping () -> [ConfigurableObject]) {
        self.childrenReader = childrenReader

        super.init(responseEverywhere: true)
        actionBlock = { [weak self] parentViewController in
            let menu = ConfigurableViewController(manifest: .init(title: self?.titleLabel.text, list: childrenReader()))
            parentViewController?.navigationController?.pushViewController(menu, animated: true)
        }
    }

    override class func configure(imageView: UIImageView) {
        imageView.image = .init(systemName: "chevron.right", withConfiguration: .largeIcon)?
            .withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .secondaryLabel
    }
}