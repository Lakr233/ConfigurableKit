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
        switch (lhs.contentValue, rhs.contentValue) {
        #if canImport(Foundation)
            case is (NSNull, NSNull), is (Void, Void):
                return true
        #endif
        case let (lhs as Bool, rhs as Bool):
            return lhs == rhs
        case let (lhs as Int, rhs as Int):
            return lhs == rhs
        case let (lhs as Int8, rhs as Int8):
            return lhs == rhs
        case let (lhs as Int16, rhs as Int16):
            return lhs == rhs
        case let (lhs as Int32, rhs as Int32):
            return lhs == rhs
        case let (lhs as Int64, rhs as Int64):
            return lhs == rhs
        case let (lhs as UInt, rhs as UInt):
            return lhs == rhs
        case let (lhs as UInt8, rhs as UInt8):
            return lhs == rhs
        case let (lhs as UInt16, rhs as UInt16):
            return lhs == rhs
        case let (lhs as UInt32, rhs as UInt32):
            return lhs == rhs
        case let (lhs as UInt64, rhs as UInt64):
            return lhs == rhs
        case let (lhs as Float, rhs as Float):
            return lhs == rhs
        case let (lhs as Double, rhs as Double):
            return lhs == rhs
        case let (lhs as String, rhs as String):
            return lhs == rhs
        case let (lhs as Data, rhs as Data):
            return lhs == rhs
        case let (lhs as Date, rhs as Date):
            return lhs == rhs
        case let (lhs as [String: ConfigurableKitAnyDecodable], rhs as [String: ConfigurableKitAnyDecodable]):
            return lhs == rhs
        case let (lhs as [ConfigurableKitAnyDecodable], rhs as [ConfigurableKitAnyDecodable]):
            return lhs == rhs
        default:
            return false
        }
    }
}

extension ConfigurableKitAnyDecodable: CustomStringConvertible {
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

extension ConfigurableKitAnyDecodable: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch contentValue {
        case let value as CustomDebugStringConvertible:
            "AnyDecodable(\(value.debugDescription))"
        default:
            "AnyDecodable(\(description))"
        }
    }
}

extension ConfigurableKitAnyDecodable: Hashable {
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
        case let value as [String: ConfigurableKitAnyDecodable]:
            hasher.combine(value)
        case let value as [ConfigurableKitAnyDecodable]:
            hasher.combine(value)
        default:
            break
        }
    }
}
