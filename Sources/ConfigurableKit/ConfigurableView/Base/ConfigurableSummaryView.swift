//
//  ConfigurableSummaryView.swift
//  TRApp
//
//  Created by 秋星桥 on 2024/2/13.
//

import Combine
import UIKit

open class ConfigurableSummaryView: ConfigurableView {
    override open func commitInit() {
        super.commitInit()
        contentContainer.removeFromSuperview()
    }
}
