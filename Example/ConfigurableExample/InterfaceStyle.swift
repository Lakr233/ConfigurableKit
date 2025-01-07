//
//  InterfaceStyle.swift
//  ConfigurableExample
//
//  Created by 秋星桥 on 2025/1/7.
//

import Foundation
import UIKit

enum InterfaceStyle: String {
    case system
    case light
    case dark

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
