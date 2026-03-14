//
//  TextInputAnnotation.swift
//  ConfigurableKit
//
//  Annotation that stores a string value and displays an inline text field.
//

import UIKit

open class TextInputAnnotation: ConfigurableObject.AnnotationProtocol {
    public let placeholder: String

    public init(placeholder: String = "") {
        self.placeholder = placeholder
    }

    @MainActor
    public func createView(fromObject object: ConfigurableObject) -> ConfigurableView {
        ConfigurableTextInputView(storage: object.valueStorage, placeholder: placeholder)
    }
}
