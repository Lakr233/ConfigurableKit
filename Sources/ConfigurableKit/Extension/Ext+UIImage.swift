//
//  Ext+UIImage.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 2025/1/5.
//

import UIKit

extension UIImage.Configuration {
    static let icon = UIImage.SymbolConfiguration(
        font: UIFont.preferredFont(forTextStyle: .subheadline)
    )
    static let largeIcon = UIImage.SymbolConfiguration(
        font: UIFont.preferredFont(forTextStyle: .subheadline),
        scale: .large
    )
}
