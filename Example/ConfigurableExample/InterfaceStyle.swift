//
//  InterfaceStyle.swift
//  ConfigurableExample
//
//  Created by 秋星桥 on 2025/1/7.
//

import Foundation
import UIKit

enum InterfaceStyle: String, CaseIterable, Codable, Sendable {
    case system
    case light
    case dark

    var title: String {
        switch self {
        case .system:
            "System"
        case .light:
            "Light"
        case .dark:
            "Dark"
        }
    }

    var subtitle: String? {
        switch self {
        case .system:
            "Follow the current system setting"
        case .light:
            "Always use a light interface"
        case .dark:
            "Always use a dark interface"
        }
    }

    var iconName: String {
        switch self {
        case .system:
            "circle.righthalf.fill"
        case .light:
            "sun.min"
        case .dark:
            "moon"
        }
    }

    var style: UIUserInterfaceStyle {
        switch self {
        case .system: .unspecified
        case .light: .light
        case .dark: .dark
        }
    }

    var appearance: NSObject? {
        switch self {
        case .system: nil
        case .light:
            (NSClassFromString("NSAppearance") as? NSObject.Type)?
                .perform(NSSelectorFromString("appearanceNamed:"), with: "NSAppearanceNameAqua")?
                .takeUnretainedValue() as? NSObject
        case .dark:
            (NSClassFromString("NSAppearance") as? NSObject.Type)?
                .perform(NSSelectorFromString("appearanceNamed:"), with: "NSAppearanceNameDarkAqua")?
                .takeUnretainedValue() as? NSObject
        }
    }
}
