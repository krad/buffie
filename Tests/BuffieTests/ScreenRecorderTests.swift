import XCTest
@testable import Buffie

#if os(macOS)
@available (macOS 10.11, *)
class ScreenRecorderTests: XCTestCase {
    
    func test_that_we_can_get_samples_from_a_screen() {
        
        let displays = Display.getAll()
        let display = displays.first
        XCTAssertNotNil(display)
        
        let mockReader = MockReader()
        let subject    = try? ScreenRecorder(display: display!, reader: mockReader)
        XCTAssertNotNil(subject)
        
        mockReader.videoExpectation = self.expectation(description: "Getting screen samples")
        subject?.start()
        self.wait(for: [mockReader.videoExpectation!], timeout: 2)
        
    }
    
    static var allTests = [
        ("test_that_we_can_get_samples_from_a_screen",
         test_that_we_can_get_samples_from_a_screen)
    ]
    
}
#endif
