import XCTest
@testable import captureCore

class FileNameParsingTests: XCTestCase {

    func test_that_we_can_determine_container_format_from_a_filename() {

        let mp4File = "output.mp4"
        let movFile = "output.mov"
        let m4vFile = "output.m4v"
        
        XCTAssertEqual(.mp4, determineContainer(from: mp4File))
        XCTAssertEqual(.mov, determineContainer(from: movFile))
        XCTAssertEqual(.m4v, determineContainer(from: m4vFile))

    }
    
}
