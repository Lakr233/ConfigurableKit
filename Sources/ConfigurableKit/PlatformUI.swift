#if canImport(UIKit)
    import UIKit

    public typealias CKView = UIView
    public typealias CKViewController = UIViewController
    public typealias CKImage = UIImage
    public typealias CKColor = UIColor
    public typealias CKFont = UIFont
    public typealias CKStackView = UIStackView
    public typealias CKScrollView = UIScrollView
    public typealias CKEdgeInsets = UIEdgeInsets
#elseif canImport(AppKit)
    import AppKit

    public typealias CKView = NSView
    public typealias CKViewController = NSViewController
    public typealias CKImage = NSImage
    public typealias CKColor = NSColor
    public typealias CKFont = NSFont
    public typealias CKStackView = NSStackView
    public typealias CKScrollView = NSScrollView
    public typealias CKEdgeInsets = NSEdgeInsets
#else
    #error("Unsupported UI framework")
#endif

public enum CKModalPresentationStyle: Sendable {
    case automatic
    case fullScreen
    case pageSheet
    case formSheet
}

@MainActor
public extension CKViewController {
    func ckPush(_ viewController: CKViewController, animated: Bool = true) {
        #if canImport(UIKit)
            if let navigationController {
                navigationController.pushViewController(viewController, animated: animated)
            } else {
                present(viewController, animated: animated)
            }
        #elseif canImport(AppKit)
            if let sheetController = ckContainingSheetController() {
                sheetController.push(viewController, animated: animated)
            } else {
                _ = animated
                presentAsModalWindow(viewController)
            }
        #endif
    }

    func ckPresentModal(
        _ viewController: CKViewController,
        style: CKModalPresentationStyle = .automatic,
        animated: Bool = true
    ) {
        #if canImport(UIKit)
            viewController.modalPresentationStyle = style.uiKitStyle
            present(viewController, animated: animated)
        #elseif canImport(AppKit)
            _ = style
            _ = animated
            if view.window != nil {
                presentAsSheet(viewController)
            } else {
                presentAsModalWindow(viewController)
            }
        #endif
    }

    func ckClose(animated: Bool = true) {
        #if canImport(UIKit)
            if let navigationController, navigationController.viewControllers.count > 1 {
                navigationController.popViewController(animated: animated)
            } else {
                dismiss(animated: animated)
            }
        #elseif canImport(AppKit)
            if let sheetController = ckContainingSheetController(),
               sheetController !== self,
               sheetController.isTopController(self)
            {
                if sheetController.canPop {
                    _ = sheetController.pop(animated: animated)
                    return
                }
            }
            _ = animated
            dismiss(nil)
            view.window?.close()
        #endif
    }
}

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    private extension CKViewController {
        func ckContainingSheetController() -> ConfigurableSheetController? {
            var current: NSViewController? = self
            while let controller = current {
                if let sheetController = controller as? ConfigurableSheetController {
                    return sheetController
                }
                current = controller.parent
            }
            return nil
        }
    }
#endif

#if canImport(UIKit)
    private extension CKModalPresentationStyle {
        var uiKitStyle: UIModalPresentationStyle {
            switch self {
            case .automatic:
                .automatic
            case .fullScreen:
                .fullScreen
            case .pageSheet:
                .pageSheet
            case .formSheet:
                .formSheet
            }
        }
    }
#endif
