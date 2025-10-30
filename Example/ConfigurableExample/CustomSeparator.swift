//
//  CustomSeparator.swift
//  ConfigurableExample
//
//  Created on 2025/10/30.
//

import ConfigurableKit
import UIKit

// Example: Custom separator with different color and height
class CustomSeparator: UIView, ConfigurableSeparatorProtocol {
    static let defaultHeight: CGFloat = 2.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBlue.withAlphaComponent(0.3)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }
}

// Example: Gradient separator
class GradientSeparator: UIView, ConfigurableSeparatorProtocol {
    static let defaultHeight: CGFloat = 1.0

    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    private func setupGradient() {
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.systemGray.withAlphaComponent(0.3).cgColor,
            UIColor.clear.cgColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.addSublayer(gradientLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
