//
//  ConfigurableView+ShareLink.swift
//  TRApp
//
//  Created by 82Flex on 2024/9/14.
//

import UIKit

open class ConfigurableShareLinkView: ConfigurableLinkView {
    @objc override open func openURL() {
        guard let viewController = parentViewController else {
            assertionFailure("ConfigurableShareLinkView requires a parent view controller to present share sheet")
            return
        }
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self
        viewController.present(activityViewController, animated: true, completion: nil)
    }
}
