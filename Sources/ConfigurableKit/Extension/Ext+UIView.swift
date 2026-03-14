//
//  Ext+UIView.swift
//  ConfigurableView
//
//  Created by 秋星桥 on 2025/1/4.
//

import UIKit

extension UIView {
    var parentViewController: UIViewController? {
        var responder: UIResponder? = next
        while let current = responder {
            if let viewController = current as? UIViewController {
                return viewController
            }
            responder = current.next
        }
        return nil
    }
}
