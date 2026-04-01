//
//  EasyHitImageView.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 2025/1/5.
//

import Foundation
#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#endif

#if canImport(UIKit)
    open class EasyHitImageView: UIImageView {
        open var easyHitInsets: UIEdgeInsets = .init(top: -16, left: -16, bottom: -16, right: -16)

        override open func point(inside point: CGPoint, with _: UIEvent?) -> Bool {
            bounds.inset(by: easyHitInsets).contains(point)
        }
    }

#elseif canImport(AppKit)
    open class EasyHitImageView: NSImageView {}
#endif
