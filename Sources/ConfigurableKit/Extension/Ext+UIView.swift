//
//  Ext+UIView.swift
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

extension CKView {
    var parentViewController: CKViewController? {
        #if canImport(UIKit)
            var responder: UIResponder? = next
            while let current = responder {
                if let viewController = current as? UIViewController {
                    return viewController
                }
                responder = current.next
            }
            return nil
        #elseif canImport(AppKit)
            var responder: NSResponder? = nextResponder
            while let current = responder {
                if let viewController = current as? NSViewController {
                    return viewController
                }
                responder = current.nextResponder
            }
            return nil
        #endif
    }
}
