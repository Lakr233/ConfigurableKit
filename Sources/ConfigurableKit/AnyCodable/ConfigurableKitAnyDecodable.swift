import Foundation

/**
 A type-erased `Decodable` value.

 The `AnyDecodable` type forwards decoding responsibilities
 to an underlying value, hiding its specific underlying type.

 You can decode mixed-type values in dictionaries
 and other collections that require `Decodable` conformance
 by declaring their contained type to be `AnyDecodable`:

     let json = """
     {
         "boolean": true,
         "integer": 42,
         "double": 3.141592653589793,
         "string": "string",
         "array": [1, 2, 3],
         "nested": {
             "a": "alpha",
             "b": "bravo",
             "c": "charlie"
         },
         "null": null
     }
     """.data(using: .utf8)!

     let decoder = JSONDecoder()
     let dictionary = try! decoder.decode([String: AnyDecodable].self, from: json)
 */
@frozen public struct ConfigurableKitAnyDecodable: Decodable {
    public let contentValue: Any

    public init(_ value: (some Any)?) {
        contentValue = value ?? ()
    }
}

@usableFromInline
protocol _AnyDecodable {
    var contentValue: Any { get }
    init(_ value: (some Any)?)
}

extension ConfigurableKitAnyDecodable: _AnyDecodable {}

extension _AnyDecodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            #if canImport(Foundation)
                self.init(NSNull())
            #else
                self.init(Self?.none)
            #endif
        } else if let bool = try? container.decode(Bool.self) {
            self.init(bool)
        } else if let int = try? container.decode(Int.self) {
            self.init(int)
        } else if let uint = try? container.decode(UInt.self) {
            self.init(uint)
        } else if let double = try? container.decode(Double.self) {
            self.init(double)
        } else if let string = try? container.decode(String.self) {
            self.init(string)
        } else if let data = try? container.decode(Data.self) {
            self.init(data)
        } else if let date = try? container.decode(Date.self) {
            self.init(date)
        } else if let array = try? container.decode([ConfigurableKitAnyDecodable].self) {
            self.init(array.map(\.contentValue))
        } else if let dictionary = try? container.decode([String: ConfigurableKitAnyDecodable].self) {
            self.init(dictionary.mapValues { $0.contentValue })
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyDecodable value cannot be decoded")
        }
    }
}

extension ConfigurableKitAnyDecodable: Equatable {
    public static func == (lhs: ConfigurableKitAnyDecodable, rhs: ConfigurableKitAnyDecodable) -> Bool {
        AnyCodableShared.isEqual(lhs.contentValue, rhs.contentValue)
    }
}

extension ConfigurableKitAnyDecodable: CustomStringConvertible {
    public var description: String {
        AnyCodableShared.description(of: contentValue)
    }
}

extension ConfigurableKitAnyDecodable: CustomDebugStringConvertible {
    public var debugDescription: String {
        AnyCodableShared.debugDescription(of: contentValue, typeName: "AnyDecodable", fallbackDescription: description)
    }
}

extension ConfigurableKitAnyDecodable: Hashable {
    public func hash(into hasher: inout Hasher) {
        AnyCodableShared.hash(contentValue, into: &hasher)
    }
}
