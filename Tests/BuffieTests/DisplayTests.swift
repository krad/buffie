import XCTest
@testable import Buffie

@available (macOS 10.11, *)
class DisplayTests: XCTestCase {
    
    func test_that_we_can_get_a_list_of_display_ids() {
        let result = Display.getIDs(for: .active)
        XCTAssert(result.count > 0)
        
        let result2 = Display.getIDs(for: .drawable)
        XCTAssert(result2.count > 0)
    }

    
    func test_that_we_can_get_a_list_of_displays() {
        let result = Display.getAll()
        XCTAssert(result.count > 0)
    }
    
    static var allTests = [
        ("test_that_we_can_get_a_list_of_display_ids",
         test_that_we_can_get_a_list_of_display_ids),

        ("test_that_we_can_get_a_list_of_displays",
         test_that_we_can_get_a_list_of_displays)
    ]
    
}
