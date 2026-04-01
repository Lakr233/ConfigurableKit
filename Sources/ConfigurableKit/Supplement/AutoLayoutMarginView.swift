//
//  AutoLayoutMarginView.swift
//  TRApp
//
//  Created by 秋星桥 on 2024/2/13.
//

import Foundation
#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#endif

public class AutoLayoutMarginView: CKView {
    public var viewInsets: CKEdgeInsets {
        didSet {
            viewTopConstraint?.constant = viewInsets.top
            viewLeadingConstraint?.constant = viewInsets.left
            viewBottomConstraint?.constant = -viewInsets.bottom
            viewTrailingConstraint?.constant = -viewInsets.right
        }
    }

    var view: CKView {
        subviews.first!
    }

    var viewTopConstraint: NSLayoutConstraint?
    var viewLeadingConstraint: NSLayoutConstraint?
    var viewBottomConstraint: NSLayoutConstraint?
    var viewTrailingConstraint: NSLayoutConstraint?

    public init(_ view: CKView, insets: CKEdgeInsets = defaultMargin) {
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
let defaultMargin = CKEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

public extension CKStackView {
    @discardableResult
    func addArrangedSubviewWithMargin(_ view: CKView, adjustMargin: (inout CKEdgeInsets) -> Void = { _ in }) -> CKView {
        var margin = defaultMargin
        adjustMargin(&margin)
        let view = AutoLayoutMarginView(view, insets: margin)
        addArrangedSubview(view)
        return view
    }

    @discardableResult
    func insertArrangedSubviewWithMargin(_ view: CKView, at stackIndex: Int, adjustMargin: (inout CKEdgeInsets) -> Void = { _ in }) -> CKView {
        var margin = defaultMargin
        adjustMargin(&margin)
        let view = AutoLayoutMarginView(view, insets: margin)
        insertArrangedSubview(view, at: stackIndex)
        return view
    }
}
