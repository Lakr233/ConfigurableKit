//
//  AvailabilityRequirement.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 2025/1/5.
//

import Foundation

public extension ConfigurableObject {
    /// Determines whether a ConfigurableObject is available (enabled/visible)
    /// based on the value of another stored configuration key.
    ///
    /// Subclass to implement custom matching logic beyond simple equality.
    class AvailabilityRequirement {
        public let key: String

        public init(key: String) {
            self.key = key
        }

        /// Override this method in subclasses to implement custom matching logic.
        /// Return `true` if the object should be available given the current `target` value.
        open func evaluate(against _: any Hashable) -> Bool {
            false
        }
    }
}

// MARK: - Built-in Requirements

public extension ConfigurableObject {
    /// Matches when the stored value equals the expected value.
    class MatchRequirement: AvailabilityRequirement {
        public let match: any Hashable

        public init(key: String, match: any Hashable = true) {
            self.match = match
            super.init(key: key)
        }

        override public func evaluate(against target: any Hashable) -> Bool {
            compareTypeAndHash(target, match)
        }

        private func compareTypeAndHash(_ target: any Hashable, _ expected: any Hashable) -> Bool {
            if let compareTarget = target as? ConfigurableKitAnyCodable {
                return ConfigurableKitAnyCodable(expected) == compareTarget
            }
            guard type(of: target) == type(of: expected) else {
                return false
            }
            return target.hashValue == expected.hashValue
        }
    }

    /// Matches when the stored value does NOT equal the expected value.
    class NegatedMatchRequirement: MatchRequirement {
        override public func evaluate(against target: any Hashable) -> Bool {
            !super.evaluate(against: target)
        }
    }
}

// MARK: - Convenience Factories

public extension ConfigurableObject.AvailabilityRequirement {
    /// Available when the value for `key` equals `match`.
    static func match(key: String, value: any Hashable = true) -> ConfigurableObject.AvailabilityRequirement {
        ConfigurableObject.MatchRequirement(key: key, match: value)
    }

    /// Available when the value for `key` does NOT equal `match`.
    static func negatedMatch(key: String, value: any Hashable = true) -> ConfigurableObject.AvailabilityRequirement {
        ConfigurableObject.NegatedMatchRequirement(key: key, match: value)
    }
}
