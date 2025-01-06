//
//  ConfigurableSheetController.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 2025/1/4.
//

import Foundation
import UIKit

open class ConfigurableSheetController: UINavigationController {
    public let controller: ConfigurableViewController

    override public var title: String? {
        set { controller.title = newValue }
        get { controller.title }
    }

    public init(manifest: ConfigurableManifest) {
        controller = .init(manifest: manifest)
        super.init(rootViewController: controller)
        
        modalTransitionStyle = .coverVertical
        modalPresentationStyle = .formSheet
        isModalInPresentation = false
        navigationBar.prefersLargeTitles = false
        preferredContentSize = .init(width: 555, height: 555 - navigationBar.frame.height)
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError()
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }

    override open func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesBegan(presses, with: event)
        for press in presses {
            if press.key?.keyCode == .keyboardEscape {
                if !isModalInPresentation {
                    dismiss(animated: true)
                }
            }
        }
    }
}
