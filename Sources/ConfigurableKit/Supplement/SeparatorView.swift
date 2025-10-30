//
//  SeparatorView.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 2025/1/4.
//

import UIKit

public protocol ConfigurableSeparatorProtocol: UIView {
    static var defaultHeight: CGFloat { get }
}

public extension ConfigurableSeparatorProtocol {
    static var defaultHeight: CGFloat { 0.5 }
}

open class SeparatorView: UIView, ConfigurableSeparatorProtocol {
    public static let color: UIColor = .gray.withAlphaComponent(0.1)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Self.color
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError()
    }
}
