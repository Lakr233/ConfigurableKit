//
//  CustomViewAnnotation.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 2025/1/5.
//

import UIKit

open class CustomViewAnnotation: ConfigurableObject.AnnotationProtocol {
    let view: () -> (UIView)
    public init(view: @escaping () -> (UIView)) {
        self.view = view
    }

    public func createView(fromObject _: ConfigurableObject) -> ConfigurableView {
        let ret = ConfigurableView()
        ret.subviews.forEach { $0.removeFromSuperview() }
        let view = view()
        ret.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        [
            view.topAnchor.constraint(equalTo: ret.topAnchor),
            view.bottomAnchor.constraint(equalTo: ret.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: ret.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: ret.trailingAnchor),
        ].forEach { $0.isActive = true }
        return ret
    }
}
