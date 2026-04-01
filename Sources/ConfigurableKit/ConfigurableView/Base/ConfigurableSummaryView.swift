//
//  ConfigurableSummaryView.swift
//  TRApp
//
//  Created by 秋星桥 on 2024/2/13.
//

import Combine
import Foundation
#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#endif

open class ConfigurableSummaryView: ConfigurableView {
    override open func commitInit() {
        super.commitInit()
        contentContainer.removeFromSuperview()
    }
}
