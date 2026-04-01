#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    import AppKit
    import QuickLookUI

    open class ConfigurableQuickLookView: ConfigurableLinkView {
        private var previewWindowController: NSWindowController?

        @objc override open func openURL() {
            let previewController = QuickLookPreviewViewController(url: url)
            let window = NSWindow(contentViewController: previewController)
            window.title = button.title
            window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
            window.setContentSize(NSSize(width: 900, height: 650))
            window.center()

            let windowController = NSWindowController(window: window)
            previewController.onClose = { [weak self] in
                self?.previewWindowController = nil
            }
            previewWindowController = windowController
            windowController.showWindow(nil)
            if #available(macOS 14.0, *) {
                NSApp.activate()
            } else {
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }

    private final class QuickLookPreviewViewController: NSViewController {
        private let url: URL
        private let previewView = QLPreviewView(frame: .zero, style: .normal)
        var onClose: (() -> Void)?

        init(url: URL) {
            self.url = url
            super.init(nibName: nil, bundle: nil)
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError()
        }

        override func loadView() {
            let root = NSView()
            root.translatesAutoresizingMaskIntoConstraints = false
            view = root
        }

        override func viewDidLoad() {
            super.viewDidLoad()

            guard let previewView else {
                NSWorkspace.shared.open(url)
                return
            }

            previewView.translatesAutoresizingMaskIntoConstraints = false
            previewView.autostarts = true
            previewView.previewItem = url as NSURL

            view.addSubview(previewView)
            NSLayoutConstraint.activate([
                previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                previewView.topAnchor.constraint(equalTo: view.topAnchor),
                previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
        }

        override func viewWillDisappear() {
            super.viewWillDisappear()
            onClose?()
        }
    }
#endif
