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
        return try Self.decoder.decode(T.self, from: data)
    }
}

extension ConfigurableKitAnyCodable: _AnyEncodable, _AnyDecodable {}

extension ConfigurableKitAnyCodable: Equatable {
    public static func == (lhs: ConfigurableKitAnyCodable, rhs: ConfigurableKitAnyCodable) -> Bool {
        AnyCodableShared.isEqual(lhs.contentValue, rhs.contentValue)
    }
}

extension ConfigurableKitAnyCodable: CustomStringConvertible {
    public var description: String {
        AnyCodableShared.description(of: contentValue)
    }
}

extension ConfigurableKitAnyCodable: CustomDebugStringConvertible {
    public var debugDescription: String {
        AnyCodableShared.debugDescription(of: contentValue, typeName: "AnyCodable", fallbackDescription: description)
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
        AnyCodableShared.hash(contentValue, into: &hasher)
    }
}
