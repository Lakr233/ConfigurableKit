//
//  Ext+UIFont.swift
//  ConfigurableView
//
//  Created by 秋星桥 on 2025/1/4.
//

import UIKit

extension UIFont {
    class func rounded(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
        return if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            UIFont(descriptor: descriptor, size: size)
        } else {
            systemFont
        }
    }

    class func rounded(ofTextStyle textStyle: TextStyle, weight: UIFont.Weight) -> UIFont {
        let systemFont = UIFont.preferredFont(forTextStyle: textStyle).withWeight(weight)
        return if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            UIFont(descriptor: descriptor, size: systemFont.pointSize)
        } else {
            systemFont
        }
    }

    var semibold: UIFont {
        withWeight(.semibold)
    }

    var medium: UIFont {
        withWeight(.medium)
    }

    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        let newDescriptor = fontDescriptor.addingAttributes([.traits: [UIFontDescriptor.TraitKey.weight: weight]])
        return UIFont(descriptor: newDescriptor, size: pointSize)
    }
}
