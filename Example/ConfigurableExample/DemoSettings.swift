//
//  DemoSettings.swift
//  ConfigurableExample
//
//  Created by GPT-5 Codex on 2025/11/10.
//

import ConfigurableKit
import UIKit

@MainActor
enum DemoSettings {
    @MainActor
    enum Keys {
        static let interfaceStyle = ConfigKey("demo.interfaceStyle", defaultValue: InterfaceStyle.system)
        static let collapseReasoning = ConfigKey("demo.collapseReasoning", defaultValue: false)
        static let confirmOnSend = ConfigKey("demo.confirmOnSend", defaultValue: true)
        static let pasteAsFile = ConfigKey("demo.pasteAsFile", defaultValue: false)
        static let compressImage = ConfigKey("demo.compressImage", defaultValue: true)
    }
}

@MainActor
struct GeneralSettingsPage: ConfigPage {
    @ConfigContentBuilder
    var body: [ConfigSectionNode] {
        Section("Display") {
            Picker(
                storage: DemoSettings.Keys.interfaceStyle,
                options: InterfaceStyle.allCases.map {
                    ConfigPickerOption(
                        value: $0,
                        title: $0.title,
                        subtitle: $0.subtitle,
                        iconSystemName: $0.iconName
                    )
                }
            )
            .title("Interface Style")
            InfoFooter("The above setting only adjusts the appearance of this demo app.")
        }

        Section("Chat") {
            Toggle(storage: DemoSettings.Keys.collapseReasoning)
                .title("Collapse Reasoning Content")
                .icon("arrow.down.right.and.arrow.up.left")
                .help("Enable this to automatically collapse reasoning content in long conversations.")
        }

        Section("Editor") {
            Toggle(storage: DemoSettings.Keys.confirmOnSend)
                .title("Confirm Before Sending")

            Toggle(storage: DemoSettings.Keys.pasteAsFile)
                .title("Paste Clipboard As File")

            Toggle(storage: DemoSettings.Keys.compressImage)
                .title("Compress Images Before Upload")
        }

        Section("Danger Zone") {
            Action("Reset Settings", role: .destructive)
                .onTap {
                    _ = ConfigurableKit.set(nil, for: DemoSettings.Keys.interfaceStyle)
                    _ = ConfigurableKit.set(false, for: DemoSettings.Keys.collapseReasoning)
                    _ = ConfigurableKit.set(true, for: DemoSettings.Keys.confirmOnSend)
                    _ = ConfigurableKit.set(false, for: DemoSettings.Keys.pasteAsFile)
                    _ = ConfigurableKit.set(true, for: DemoSettings.Keys.compressImage)
                }
                .subtitle("Restore all example values back to defaults.")
                .icon("arrow.counterclockwise")
        }
    }
}
