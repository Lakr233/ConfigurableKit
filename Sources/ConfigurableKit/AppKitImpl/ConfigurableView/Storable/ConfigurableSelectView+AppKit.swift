#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    import AppKit

    open class ConfigurableSelectView: ConfigurableStorableView {
        open var button: NSButton {
            contentView as! NSButton
        }

        let selection: () -> [MenuAnnotation.Option]

        public init(storage: CodableStorage, selection: @escaping () -> [MenuAnnotation.Option]) {
            self.selection = selection
            super.init(storage: storage)

            button.target = self
            button.action = #selector(openMenu)
            button.isBordered = false
            button.alignment = .right
            button.font = NSFont.preferredFont(forTextStyle: .subheadline).semibold
            rebuildMenu()
        }

        override open class func createContentView() -> NSView {
            let button = NSButton(title: "", target: nil, action: nil)
            button.setButtonType(.momentaryPushIn)
            button.isBordered = false
            button.alignment = .right
            button.lineBreakMode = .byTruncatingTail
            button.setContentHuggingPriority(.defaultLow, for: .horizontal)
            button.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            return button
        }

        override open func updateValue() {
            super.updateValue()
            rebuildMenu()
        }

        func rebuildMenu() {
            let selections = selection()
            updateButtonTitle(selections: selections)
        }

        func updateButtonTitle(selections: [MenuAnnotation.Option]) {
            guard !selections.isEmpty else {
                let text = String(localized: String.LocalizationValue("Unspecified"))
                button.attributedTitle = NSAttributedString(string: text, attributes: [
                    .foregroundColor: NSColor.secondaryLabelColor,
                    .font: NSFont.preferredFont(forTextStyle: .subheadline).semibold,
                ])
                button.isEnabled = false
                return
            }

            button.isEnabled = true

            var selectedText: String = value.decodingValue(defaultValue: String(describing: value))
            for item in selections where item.rawValue == value {
                selectedText = String(localized: item.title)
                break
            }
            if selectedText.isEmpty {
                selectedText = String(localized: String.LocalizationValue("Unspecified"))
            }

            let normalAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: NSColor.accent,
                .font: NSFont.preferredFont(forTextStyle: .subheadline).semibold,
                .underlineStyle: NSUnderlineStyle.single.rawValue,
            ]
            button.attributedTitle = NSAttributedString(string: selectedText, attributes: normalAttributes)
        }

        @objc open func openMenu() {
            let selections = selection()
            guard !selections.isEmpty else { return }

            let menu = NSMenu()
            menu.autoenablesItems = false
            var displaySection = ""
            var needsLeadingSeparator = false

            for option in selections {
                let section = String(localized: option.section)
                if section != displaySection {
                    if !displaySection.isEmpty || needsLeadingSeparator {
                        menu.addItem(.separator())
                    }
                    displaySection = section
                    if !section.isEmpty {
                        let header = NSMenuItem(title: section, action: nil, keyEquivalent: "")
                        header.isEnabled = false
                        menu.addItem(header)
                    }
                    needsLeadingSeparator = true
                }

                let item = NSMenuItem(
                    title: String(localized: option.title),
                    action: #selector(selectionChanged(_:)),
                    keyEquivalent: ""
                )
                item.target = self
                item.state = option.rawValue == value ? .on : .off
                item.representedObject = option.rawValue

                if !option.icon.isEmpty {
                    if option.icon.hasPrefix("#") {
                        item.image = NSImage(named: NSImage.Name(String(option.icon.dropFirst())))
                    } else {
                        item.image = NSImage(systemSymbolName: option.icon, accessibilityDescription: nil)
                    }
                }
                menu.addItem(item)
            }

            menu.popUp(positioning: nil, at: NSPoint(x: button.bounds.maxX, y: -4), in: button)
        }

        @objc open func selectionChanged(_ sender: NSMenuItem) {
            guard let selectedValue = sender.representedObject as? ConfigurableKitAnyCodable else { return }
            value = selectedValue
        }
    }
#endif
