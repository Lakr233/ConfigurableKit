//
//  ConfigurableView+QuickLook.swift
//  TRApp
//
//  Created by 82Flex on 2024/9/14.
//

import QuickLook
import UIKit

open class ConfigurableQuickLookView: ConfigurableLinkView, QLPreviewControllerDataSource {
    @objc override open func openURL() {
        let previewController = QLPreviewController()
        previewController.dataSource = self
        if let viewController = parentViewController {
            viewController.present(previewController, animated: true, completion: nil)
        }
    }

    open func numberOfPreviewItems(in _: QLPreviewController) -> Int {
        1
    }

    open func previewController(_: QLPreviewController, previewItemAt _: Int) -> any QLPreviewItem {
        url as QLPreviewItem
    }
}
