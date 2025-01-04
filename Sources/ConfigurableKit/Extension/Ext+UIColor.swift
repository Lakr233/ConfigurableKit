//
//  Ext+UIColor.swift
//  ConfigurableView
//
//  Created by 秋星桥 on 2025/1/4.
//

import UIKit

extension UIColor {
    static var accent: UIColor {
        if let color = UIColor(named: "AccentColor") {
            return color
        }
        if let color = UIColor(named: "accent") {
            return color
        }
        return .systemBlue
    }
}
