//
//  ConfigurableObject+View.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 2025/1/4.
//

import UIKit

extension ConfigurableObject {
    func createView() -> UIView? {
        let view = annotation.createView(fromObject: self)
        view.configure(icon: .image(optionalName: icon))
        view.configure(title: title)
        view.configure(description: explain)
        if let availabilityRequirement {
            let publisher = __value.storage.valueUpdatePublisher
                .filter { $0.0 == availabilityRequirement.key }
                .map { $0.1 ?? .init() }
                .map { CodableStorage.decode(data: $0) ?? .init() }
                .map { availabilityRequirement.compare(with: $0) }
                .eraseToAnyPublisher()
            let initialValue = __value.storage.value(forKey: availabilityRequirement.key)
                .map { CodableStorage.decode(data: $0) ?? .init() }
                .map { availabilityRequirement.compare(with: $0) } ?? false
            view.subscribeToAvailability(publisher, initialValue: initialValue)
        }
        return view
    }
}

extension UIImage {
    static func image(optionalName: String) -> UIImage? {
        var image: UIImage?
        if image == nil { image = .init(systemName: optionalName) }
        if image == nil { image = .init(named: optionalName) }
        return image
    }
}
