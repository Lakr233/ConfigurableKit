//
//  SeparatorView.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 2025/1/4.
//

//
//  SeparatorView.swift
//  TRApp
//
//  Created by 秋星桥 on 2024/2/13.
//

import UIKit

class SeparatorView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .gray.withAlphaComponent(0.1)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }
}
