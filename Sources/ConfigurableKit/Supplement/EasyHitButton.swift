//
//  EasyHitButton.swift
//  ConfigurableView
//
//  Created by 秋星桥 on 2025/1/4.
//

import Foundation
#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#endif

#if canImport(UIKit)
    open class EasyHitButton: UIButton {
        open var easyHitInsets: UIEdgeInsets = .init(top: -16, left: -16, bottom: -16, right: -16)

        override open func point(inside point: CGPoint, with _: UIEvent?) -> Bool {
            bounds.inset(by: easyHitInsets).contains(point)
        }

        /// Set by `ConfigurableView` while the title wraps, so every line stays
        /// aligned to the trailing edge even after the button sets a new title.
        var wrappedTitleAlignment: NSTextAlignment? {
            didSet {
                guard oldValue != wrappedTitleAlignment else { return }
                setNeedsLayout()
            }
        }

        override open func layoutSubviews() {
            super.layoutSubviews()
            if let wrappedTitleAlignment, let titleLabel, titleLabel.textAlignment != wrappedTitleAlignment {
                titleLabel.textAlignment = wrappedTitleAlignment
            }
        }
    }

#elseif canImport(AppKit)
    open class EasyHitButton: NSButton {}
#endif
