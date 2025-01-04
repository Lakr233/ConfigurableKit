//
//  EasyHitButton.swift
//  ConfigurableView
//
//  Created by 秋星桥 on 2025/1/4.
//

import UIKit

class EasyHitButton: UIButton {
    var easyHitInsets: UIEdgeInsets = .init(top: -16, left: -16, bottom: -16, right: -16)

    override func point(inside point: CGPoint, with _: UIEvent?) -> Bool {
        bounds.inset(by: easyHitInsets).contains(point)
    }
}
