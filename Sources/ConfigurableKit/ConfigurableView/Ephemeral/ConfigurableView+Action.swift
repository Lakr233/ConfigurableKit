//
//  ConfigurableView+Action.swift
//  TRApp
//
//  Created by 82Flex on 2024/9/14.
//

import Combine
import UIKit

open class ConfigurableActionView: ConfigurableView, UIGestureRecognizerDelegate {
    open var actionBlock: @MainActor (UIViewController) async -> Void

    open lazy var pressGesture: UILongPressGestureRecognizer = .init(
        target: self,
        action: #selector(viewPressed(_:))
    )
    open lazy var tapGesture: UITapGestureRecognizer = .init(
        target: self,
        action: #selector(openItem)
    )

    open var imageView: UIImageView { contentView as! UIImageView }

    open var isHighlighted: Bool = false {
        didSet {
            guard oldValue != isHighlighted else { return }
            let value = isHighlighted
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut) { [weak self] in
                self?.alpha = value ? 0.5 : 1
            }
        }
    }

    public init(responseEverywhere: Bool = true, actionBlock: @escaping @MainActor ((UIViewController) async -> Void) = { _ in }) {
        self.actionBlock = actionBlock
        super.init()
        contentView.contentMode = .scaleAspectFit

        pressGesture.minimumPressDuration = 0
        pressGesture.delegate = self

        if responseEverywhere {
            addGestureRecognizer(tapGesture)
            addGestureRecognizer(pressGesture)
        } else {
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(tapGesture)
            imageView.addGestureRecognizer(pressGesture)
        }
    }

    @available(*, unavailable)
    public required init(coder _: NSCoder) {
        fatalError()
    }

    override open class func createContentView() -> UIView {
        let view = EasyHitImageView()
        view.contentMode = .scaleAspectFit
        configure(imageView: view)
        return view
    }

    open class func configure(imageView: UIImageView) {
        imageView.image = .init(systemName: "arrow.right.circle.fill", withConfiguration: .largeIcon)?
            .withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .accent
    }

    @objc open func viewPressed(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            isHighlighted = true
        } else if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
            isHighlighted = false
        }
    }

    open func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        true
    }

    @objc open func openItem() {
        guard let parentViewController else {
            assertionFailure("ConfigurableActionView requires a parent view controller to execute actions")
            return
        }
        Task { @MainActor in
            await actionBlock(parentViewController)
        }
    }
}
