import XCTest
@testable import Buffie

class AtomTests: XCTestCase {
    
    func test_that_we_can_encode_an_ftyp_atom() {
        
        let ftyp    = FTYP()
        let bytes   = try? BinaryEncoder.encode(ftyp)
        XCTAssertNotNil(bytes)
        
        let data = Data(bytes: bytes!)
        let hexData = data.hexEncodedString()
        XCTAssertEqual(hexData,
                       "00000020667479706d703432000000016d7034316d70343269736f6d686c7366")
    }
    
    func test_that_we_can_encode_an_mvhd_atom() {
        
        let mvhd = MVHD()
        let bytes = try? BinaryEncoder.encode(mvhd)
        XCTAssertNotNil(bytes)
        
        let data = Data(bytes: bytes!)
        let hexData = data.hexEncodedString()

        XCTAssertEqual(hexData, "0000006c6d76686400000000d627cae4d627cae40000ac44000000000001000001000000000000000000000000010000000000000000000000000000000100000000000000000000000000004000000000000000000000000000000000000000000000000000000000000003")
    }
    
}

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}
