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
    
    func test_that_we_can_get_a_screen_input() {
        let result = Display.getAll().first
        XCTAssertNotNil(result)
        XCTAssertNotNil(result?.input)
    }
    
    func test_that_we_can_get_a_localized_name_for_the_display() {
        let result = Display.getAll().first
        XCTAssertEqual("Color LCD", result?.name)
    }
    
    static var allTests = [
        ("test_that_we_can_get_a_list_of_display_ids",
         test_that_we_can_get_a_list_of_display_ids),

        ("test_that_we_can_get_a_list_of_displays",
         test_that_we_can_get_a_list_of_displays),
        
        ("test_that_we_can_get_a_screen_input",
         test_that_we_can_get_a_screen_input),
    ]
    
}
