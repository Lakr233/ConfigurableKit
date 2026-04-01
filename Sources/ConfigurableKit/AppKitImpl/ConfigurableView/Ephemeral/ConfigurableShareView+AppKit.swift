#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    import AppKit

    open class ConfigurableShareView: ConfigurableLinkView {
        @objc override open func openURL() {
            let picker = NSSharingServicePicker(items: [url])
            picker.show(relativeTo: bounds, of: self, preferredEdge: .minY)
        }
    }
#endif
