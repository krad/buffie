/// This comes from Mike Ash's work on implementing a Codeable implemention of a binary encoder/decoder
/// https://github.com/mikeash/BinaryCoder
/// https://www.mikeash.com/pyblog/friday-qa-2017-07-28-a-binary-coder-for-swift.html

/// Implementations of BinaryCodable for built-in types.
import Foundation


extension Array: BinaryEncodable {
    public func binaryEncode(to encoder: BinaryEncoder) throws {
        guard Element.self is Encodable.Type else {
            throw BinaryEncoder.Error.typeNotConformingToEncodable(Element.self)
        }
        
        //KRAD: We don't need this because we're not going to be decoding
        //try encoder.encode(self.count)
        for element in self {
            try (element as! Encodable).encode(to: encoder)
        }
    }
}

extension String: BinaryEncodable {
    public func binaryEncode(to encoder: BinaryEncoder) throws {
        try Array(self.utf8).binaryEncode(to: encoder)
    }
}

extension FixedWidthInteger where Self: BinaryEncodable {
    public func binaryEncode(to encoder: BinaryEncoder) {
        encoder.appendBytes(of: self.bigEndian)
    }
}

extension Int8: BinaryEncodable {}
extension UInt8: BinaryEncodable {}
extension Int16: BinaryEncodable {}
extension UInt16: BinaryEncodable {}
extension Int32: BinaryEncodable {}
extension UInt32: BinaryEncodable {}
extension Int64: BinaryEncodable {}
extension UInt64: BinaryEncodable {}