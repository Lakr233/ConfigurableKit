//
//  AvailabilityRequirement.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 2025/1/5.
//

import Foundation

public extension ConfigurableObject {
    struct AvailabilityRequirement {
        let key: String
        let match: any Hashable
        let reversed: Bool

        public init(key: String, match: any Hashable = true, reversed: Bool = false) {
            self.key = key
            self.match = match
            self.reversed = reversed
        }
    }
}

extension ConfigurableObject.AvailabilityRequirement {
    // for better readability, compiler will handle the optimisation
    func compare(with target: any Hashable) -> Bool {
        let result = compareTypeAndHash(with: target)
        switch reversed {
        case true: return !result
        case false: return result
        }
    }

    private func compareTypeAndHash(with target: any Hashable) -> Bool {
        if let compareTarget = target as? ConfigurableKitAnyCodable {
            return ConfigurableKitAnyCodable(match) == compareTarget
        }
        guard type(of: target) == type(of: match) else {
            return false
        }
        return target.hashValue == match.hashValue
    }
}
