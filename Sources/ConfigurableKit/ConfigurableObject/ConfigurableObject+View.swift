//
//  ConfigurableObject+View.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 2025/1/4.
//

import UIKit

public extension ConfigurableObject {
    @MainActor
    func createView() -> ConfigurableView {
        let view = annotation.createView(fromObject: self)
        view.configure(icon: .image(optionalName: icon))
        view.configure(title: title)
        view.configure(description: explain)

        metadataDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self, weak view] in
                guard let self, let view else { return }
                view.configure(icon: .image(optionalName: icon))
                view.configure(title: title)
                view.configure(description: explain)
            }
            .store(in: &view.cancellables)

        if let availabilityRequirement {
            let publisher = valueStorage.storage.valueUpdatePublisher
                .filter { $0.0 == availabilityRequirement.key }
                .map { $0.1 ?? .init() }
                .map { CodableStorage.decode(data: $0) ?? .init() }
                .map { availabilityRequirement.evaluate(against: $0) }
                .eraseToAnyPublisher()
            let initialValue = valueStorage.storage.value(forKey: availabilityRequirement.key)
                .map { CodableStorage.decode(data: $0) ?? .init() }
                .map { availabilityRequirement.evaluate(against: $0) } ?? false
            view.subscribeToAvailability(publisher, initialValue: initialValue)
        }
        return view
    }
}

public extension UIImage {
    static func image(optionalName: String) -> UIImage? {
        var image: UIImage?
        if image == nil { image = .init(systemName: optionalName) }
        if image == nil { image = .init(named: optionalName) }
        return image
    }
}
