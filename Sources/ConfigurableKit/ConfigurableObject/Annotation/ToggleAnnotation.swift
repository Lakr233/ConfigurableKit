//
//  ToggleAnnotation.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 2025/1/5.
//

import Foundation

open class ToggleAnnotation: ConfigurableObject.AnnotationProtocol {
    @MainActor
    public func createView(fromObject object: ConfigurableObject) -> ConfigurableView {
        ConfigurableToggleView(storage: object.valueStorage)
    }
}
