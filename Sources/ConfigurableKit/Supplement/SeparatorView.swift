//
//  SeparatorView.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 2025/1/4.
//

import Foundation

public protocol ConfigurableSeparatorProtocol: CKView {
    static var defaultHeight: CGFloat { get }
}

public extension ConfigurableSeparatorProtocol {
    static var defaultHeight: CGFloat {
        0.5
    }
}

open class SeparatorView: CKView, ConfigurableSeparatorProtocol {
    public static let color: CKColor = .gray.withAlphaComponent(0.1)

    override init(frame: CGRect) {
        super.init(frame: frame)
        #if canImport(UIKit)
            backgroundColor = Self.color
        #elseif canImport(AppKit)
            wantsLayer = true
            layer?.backgroundColor = Self.color.cgColor
        #endif
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError()
    }
}
