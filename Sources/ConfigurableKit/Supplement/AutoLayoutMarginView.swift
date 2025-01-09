//
//  AutoLayoutMarginView.swift
//  TRApp
//
//  Created by 秋星桥 on 2024/2/13.
//

import UIKit

public class AutoLayoutMarginView: UIView {
    public var viewInsets: UIEdgeInsets {
        didSet {
            viewTopConstraint?.constant = viewInsets.top
            viewLeadingConstraint?.constant = viewInsets.left
            viewBottomConstraint?.constant = -viewInsets.bottom
            viewTrailingConstraint?.constant = -viewInsets.right
        }
    }

    var view: UIView { subviews.first! }

    var viewTopConstraint: NSLayoutConstraint?
    var viewLeadingConstraint: NSLayoutConstraint?
    var viewBottomConstraint: NSLayoutConstraint?
    var viewTrailingConstraint: NSLayoutConstraint?

    public init(_ view: UIView, insets: UIEdgeInsets = defaultMargin) {
        viewInsets = insets
        super.init(frame: .zero)
        addSubview(view)
        translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        viewTopConstraint = view.topAnchor.constraint(equalTo: topAnchor, constant: insets.top)
        viewLeadingConstraint = view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left)
        viewBottomConstraint = view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets.bottom)
        viewTrailingConstraint = view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets.right)
        NSLayoutConstraint.activate([
            viewTopConstraint,
            viewLeadingConstraint,
            viewBottomConstraint,
            viewTrailingConstraint,
        ].compactMap(\.self))
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }
}

@usableFromInline
let defaultMargin = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

public extension UIStackView {
    @discardableResult
    func addArrangedSubviewWithMargin(_ view: UIView, adjustMargin: (inout UIEdgeInsets) -> Void = { _ in }) -> UIView {
        var margin = defaultMargin
        adjustMargin(&margin)
        let view = AutoLayoutMarginView(view, insets: margin)
        addArrangedSubview(view)
        return view
    }

    @discardableResult
    func insertArrangedSubviewWithMargin(_ view: UIView, at stackIndex: Int, adjustMargin: (inout UIEdgeInsets) -> Void = { _ in }) -> UIView {
        var margin = defaultMargin
        adjustMargin(&margin)
        let view = AutoLayoutMarginView(view, insets: margin)
        insertArrangedSubview(view, at: stackIndex)
        return view
    }
}
