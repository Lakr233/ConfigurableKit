//
//  StackScrollController.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 2025/1/4.
//

import UIKit

open class StackScrollController: UIViewController {
    public let scrollView = UIScrollView()
    public let contentView = UIView()
    public let stackView = UIStackView()

    override open func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .equalSpacing

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)

        scrollView.clipsToBounds = false
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.contentInset = .init(top: 0, left: 0, bottom: 32, right: 0)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor),

            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: 0),
        ])

        setupContentViews()
        stackView
            .subviews
            .compactMap { view -> SeparatorView? in
                if view is SeparatorView {
                    return view as? SeparatorView
                }
                return nil
            }.forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    $0.heightAnchor.constraint(equalToConstant: 0.5),
                    $0.widthAnchor.constraint(equalTo: stackView.widthAnchor),
                ])
            }
    }

    open func setupContentViews() { /* stub */ }
}
