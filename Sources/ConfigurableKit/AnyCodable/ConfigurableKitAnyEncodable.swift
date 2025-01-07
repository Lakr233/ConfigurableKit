import Foundation

/**
 A type-erased `Encodable` value.

 The `AnyEncodable` type forwards encoding responsibilities
 to an underlying value, hiding its specific underlying type.

 You can encode mixed-type values in dictionaries
 and other collections that require `Encodable` conformance
 by declaring their contained type to be `AnyEncodable`:

     let dictionary: [String: AnyEncodable] = [
         "boolean": true,
         "integer": 42,
         "double": 3.141592653589793,
         "string": "string",
         "array": [1, 2, 3],
         "nested": [
             "a": "alpha",
             "b": "bravo",
             "c": "charlie"
         ],
         "null": nil
     ]

     let encoder = JSONEncoder()
     let json = try! encoder.encode(dictionary)
 */
@frozen public struct ConfigurableKitAnyEncodable: Encodable {
    public let contentValue: Any

    public init(_ value: (some Any)?) {
        contentValue = value ?? ()
    }
}

@usableFromInline
protocol _AnyEncodable {
    var contentValue: Any { get }
    init<T>(_ value: T?)
}

extension ConfigurableKitAnyEncodable: _AnyEncodable {}

// MARK: - Encodable

extension _AnyEncodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch contentValue {
        #if canImport(Foundation)
            case is NSNull:
                try container.encodeNil()
        #endif
        case is Void:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let int8 as Int8:
            try container.encode(int8)
        case let int16 as Int16:
            try container.encode(int16)
        case let int32 as Int32:
            try container.encode(int32)
        case let int64 as Int64:
            try container.encode(int64)
        case let uint as UInt:
            try container.encode(uint)
        case let uint8 as UInt8:
            try container.encode(uint8)
        case let uint16 as UInt16:
            try container.encode(uint16)
        case let uint32 as UInt32:
            try container.encode(uint32)
        case let uint64 as UInt64:
            try container.encode(uint64)
        case let float as Float:
            try container.encode(float)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let data as Data:
            try container.encode(data)
        case let date as Date:
            try container.encode(date)
        #if canImport(Foundation)
            case let number as NSNumber:
                try encode(nsnumber: number, into: &container)
            case let date as Date:
                try container.encode(date)
            case let url as URL:
                try container.encode(url)
        #endif
        case let array as [Any?]:
            try container.encode(array.map { ConfigurableKitAnyEncodable($0) })
        case let dictionary as [String: Any?]:
            try container.encode(dictionary.mapValues { ConfigurableKitAnyEncodable($0) })
        case let encodable as Encodable:
            try encodable.encode(to: encoder)
        default:
            let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "AnyEncodable value cannot be encoded")
            throw EncodingError.invalidValue(contentValue, context)
        }
    }

    #if canImport(Foundation)
        func encode(nsnumber: NSNumber, into container: inout SingleValueEncodingContainer) throws {
            switch Character(Unicode.Scalar(UInt8(nsnumber.objCType.pointee))) {
            case "B":
                try container.encode(nsnumber.boolValue)
            case "c":
                try container.encode(nsnumber.int8Value)
            case "s":
                try container.encode(nsnumber.int16Value)
            case "i", "l":
                try container.encode(nsnumber.int32Value)
            case "q":
                try container.encode(nsnumber.int64Value)
            case "C":
                try container.encode(nsnumber.uint8Value)
            case "S":
                try container.encode(nsnumber.uint16Value)
            case "I", "L":
                try container.encode(nsnumber.uint32Value)
            case "Q":
                try container.encode(nsnumber.uint64Value)
            case "f":
                try container.encode(nsnumber.floatValue)
            case "d":
                try container.encode(nsnumber.doubleValue)
            default:
                let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "NSNumber cannot be encoded because its type is not handled")
                throw EncodingError.invalidValue(nsnumber, context)
            }
        }
    #endif
}

extension ConfigurableKitAnyEncodable: Equatable {
    public static func == (lhs: ConfigurableKitAnyEncodable, rhs: ConfigurableKitAnyEncodable) -> Bool {
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
        case let (lhs as [String: ConfigurableKitAnyEncodable], rhs as [String: ConfigurableKitAnyEncodable]):
            lhs == rhs
        case let (lhs as [ConfigurableKitAnyEncodable], rhs as [ConfigurableKitAnyEncodable]):
            lhs == rhs
        default:
            false
        }
    }
}

extension ConfigurableKitAnyEncodable: CustomStringConvertible {
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

extension ConfigurableKitAnyEncodable: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch contentValue {
        case let value as CustomDebugStringConvertible:
            "AnyEncodable(\(value.debugDescription))"
        default:
            "AnyEncodable(\(description))"
        }
    }
}

extension ConfigurableKitAnyEncodable: ExpressibleByNilLiteral {}
extension ConfigurableKitAnyEncodable: ExpressibleByBooleanLiteral {}
extension ConfigurableKitAnyEncodable: ExpressibleByIntegerLiteral {}
extension ConfigurableKitAnyEncodable: ExpressibleByFloatLiteral {}
extension ConfigurableKitAnyEncodable: ExpressibleByStringLiteral {}
extension ConfigurableKitAnyEncodable: ExpressibleByStringInterpolation {}
extension ConfigurableKitAnyEncodable: ExpressibleByArrayLiteral {}
extension ConfigurableKitAnyEncodable: ExpressibleByDictionaryLiteral {}

extension _AnyEncodable {
    public init(nilLiteral _: ()) {
        self.init(nil as Any?)
    }

    public init(booleanLiteral value: Bool) {
        self.init(value)
    }

    public init(integerLiteral value: Int) {
        self.init(value)
    }

    public init(floatLiteral value: Double) {
        self.init(value)
    }

    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(value)
    }

    public init(stringLiteral value: String) {
        self.init(value)
    }

    public init(arrayLiteral elements: Any...) {
        self.init(elements)
    }

    public init(dictionaryLiteral elements: (AnyHashable, Any)...) {
        self.init([AnyHashable: Any](elements, uniquingKeysWith: { first, _ in first }))
    }
}

extension ConfigurableKitAnyEncodable: Hashable {
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
        case let value as [String: ConfigurableKitAnyEncodable]:
            hasher.combine(value)
        case let value as [ConfigurableKitAnyEncodable]:
            hasher.combine(value)
        default:
            break
        }
    }
}