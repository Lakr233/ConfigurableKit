import Foundation

/**
 A type-erased `Codable` value.

 The `AnyCodable` type forwards encoding and decoding responsibilities
 to an underlying value, hiding its specific underlying type.

 You can encode or decode mixed-type values in dictionaries
 and other collections that require `Encodable` or `Decodable` conformance
 by declaring their contained type to be `AnyCodable`.

 - SeeAlso: `AnyEncodable`
 - SeeAlso: `AnyDecodable`
 */
@frozen
public struct ConfigurableKitAnyCodable: Codable {
    @usableFromInline
    let contentValue: Any

    public init(_ value: (some Any)?) {
        contentValue = value ?? ()
    }

    public func decodingValue<T: Codable>(defaultValue: T) -> T {
        (try? decodingValue()) ?? defaultValue
    }

    private static let encoder = JSONEncoder()
    private static let decoder = JSONDecoder()

    public func decodingValue<T: Codable>() throws -> T? {
        if let value = contentValue as? T { return value }
        // code and decode the value for conversion
        let data = try Self.encoder.encode(self)
        let object = try Self.decoder.decode(T.self, from: data)
        return object
    }
}

extension ConfigurableKitAnyCodable: _AnyEncodable, _AnyDecodable {}

extension ConfigurableKitAnyCodable: Equatable {
    public static func == (lhs: ConfigurableKitAnyCodable, rhs: ConfigurableKitAnyCodable) -> Bool {
        switch (lhs.contentValue, rhs.contentValue) {
        case is (Void, Void):
            true
        case let (lhs as Bool, rhs as Bool):
            lhs == rhs
        case let (lhs as Int, rhs as Int):
            lhs == rhs
        case let (lhs as Int8, rhs as Int8):
            lhs == rhs
        case let (lhs as Int16, rhs as Int16):
            lhs == rhs
        case let (lhs as Int32, rhs as Int32):
            lhs == rhs
        case let (lhs as Int64, rhs as Int64):
            lhs == rhs
        case let (lhs as UInt, rhs as UInt):
            lhs == rhs
        case let (lhs as UInt8, rhs as UInt8):
            lhs == rhs
        case let (lhs as UInt16, rhs as UInt16):
            lhs == rhs
        case let (lhs as UInt32, rhs as UInt32):
            lhs == rhs
        case let (lhs as UInt64, rhs as UInt64):
            lhs == rhs
        case let (lhs as Float, rhs as Float):
            lhs == rhs
        case let (lhs as Double, rhs as Double):
            lhs == rhs
        case let (lhs as String, rhs as String):
            lhs == rhs
        case let (lhs as Data, rhs as Data):
            lhs == rhs
        case let (lhs as Date, rhs as Date):
            lhs == rhs
        case let (lhs as [String: ConfigurableKitAnyCodable], rhs as [String: ConfigurableKitAnyCodable]):
            lhs == rhs
        case let (lhs as [ConfigurableKitAnyCodable], rhs as [ConfigurableKitAnyCodable]):
            lhs == rhs
        case let (lhs as [String: Any], rhs as [String: Any]):
            NSDictionary(dictionary: lhs) == NSDictionary(dictionary: rhs)
        case let (lhs as [Any], rhs as [Any]):
            NSArray(array: lhs) == NSArray(array: rhs)
        case is (NSNull, NSNull):
            true
        default:
            false
        }
    }
}

extension ConfigurableKitAnyCodable: CustomStringConvertible {
    public var description: String {
        switch contentValue {
        case is Void:
            String(describing: nil as Any?)
        case let value as CustomStringConvertible:
            value.description
        default:
            String(describing: contentValue)
        }
    }
}

extension ConfigurableKitAnyCodable: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch contentValue {
        case let value as CustomDebugStringConvertible:
            "AnyCodable(\(value.debugDescription))"
        default:
            "AnyCodable(\(description))"
        }
    }
}

extension ConfigurableKitAnyCodable: ExpressibleByNilLiteral {}
extension ConfigurableKitAnyCodable: ExpressibleByBooleanLiteral {}
extension ConfigurableKitAnyCodable: ExpressibleByIntegerLiteral {}
extension ConfigurableKitAnyCodable: ExpressibleByFloatLiteral {}
extension ConfigurableKitAnyCodable: ExpressibleByStringLiteral {}
extension ConfigurableKitAnyCodable: ExpressibleByStringInterpolation {}
extension ConfigurableKitAnyCodable: ExpressibleByArrayLiteral {}
extension ConfigurableKitAnyCodable: ExpressibleByDictionaryLiteral {}

extension ConfigurableKitAnyCodable: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch contentValue {
        case let value as Bool:
            hasher.combine(value)
        case let value as Int:
            hasher.combine(value)
        case let value as Int8:
            hasher.combine(value)
        case let value as Int16:
            hasher.combine(value)
        case let value as Int32:
            hasher.combine(value)
        case let value as Int64:
            hasher.combine(value)
        case let value as UInt:
            hasher.combine(value)
        case let value as UInt8:
            hasher.combine(value)
        case let value as UInt16:
            hasher.combine(value)
        case let value as UInt32:
            hasher.combine(value)
        case let value as UInt64:
            hasher.combine(value)
        case let value as Float:
            hasher.combine(value)
        case let value as Double:
            hasher.combine(value)
        case let value as String:
            hasher.combine(value)
        case let value as Data:
            hasher.combine(value)
        case let value as Date:
            hasher.combine(value)
        case let value as [String: ConfigurableKitAnyCodable]:
            hasher.combine(value)
        case let value as [ConfigurableKitAnyCodable]:
            hasher.combine(value)
        default:
            break
        }
    }
}
