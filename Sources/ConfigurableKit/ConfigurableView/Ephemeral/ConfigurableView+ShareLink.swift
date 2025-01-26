//
//  ConfigurableView+ShareLink.swift
//  TRApp
//
//  Created by 82Flex on 2024/9/14.
//

import UIKit

open class ConfigurableShareLinkView: ConfigurableLinkView {
    @objc override open func openURL() {
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self
        if let viewController = parentViewController {
            viewController.present(activityViewController, animated: true, completion: nil)
        }
    }
}
