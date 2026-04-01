//
//  Ext+UIStackView.swift
//  ConfigurableView
//
//  Created by 秋星桥 on 2025/1/4.
//

import Foundation

extension CKStackView {
    func addArrangedSubviews(_ views: [CKView]) {
        views.forEach { addArrangedSubview($0) }
    }
}
