import XCTest
@testable import Buffie

class AtomTests: XCTestCase {
    
    var testCases: [(BinaryEncodable, String)] = [
        (FTYP(), "00000020667479706d703432000000016d7034316d70343269736f6d686c7366"),
        
        (MVHD(), "0000006c6d76686400000000d627cae4d627cae40000ac44000000000001000001000000000000000000000000010000000000000000000000000000000100000000000000000000000000004000000000000000000000000000000000000000000000000000000000000003"),
        
        (TKHD(), "0000005c746b686400000001d627cae4d627cae4000000010000000000000000000000000000000000000000010000000001000000000000000000000000000000010000000000000000000000000000400000000500000002d00000"),
        
        (MDHD(), "000000206d64686400000000d627cae4d627cae40000753000000bbb55c40000")
        
    ]
    
    func test_that_we_can_encode_atoms_to_their_proper_binary_representations() {
        
        for testCase in testCases {
            
            let bytes = try? BinaryEncoder.encode(testCase.0)
            XCTAssertNotNil(bytes)
            
            let data    = Data(bytes: bytes!)
            let hexData = data.hexEncodedString()
            XCTAssertEqual(hexData, testCase.1)
            
        }
        
    }
    
}

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}
