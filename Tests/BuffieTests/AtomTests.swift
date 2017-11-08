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
        
        let url = URL(fileURLWithPath: "/tmp/ftyp.mp4")
        try? data.write(to: url)
    }
    
}

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}
