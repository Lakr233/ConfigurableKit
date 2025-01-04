//
//  BooleanAnnotation.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 2025/1/5.
//

import UIKit

open class BooleanAnnotation: ConfigurableObject.AnnotationProtocol {
    public func createView(fromObject object: ConfigurableObject) -> ConfigurableView {
        ConfigurableBooleanView(storage: object.__value)
    }
}
