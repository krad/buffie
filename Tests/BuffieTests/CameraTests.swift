import XCTest
import CoreMedia
@testable import Buffie

class CameraTests: XCTestCase {
    
    func test_basic_object_behavior() {
        
        let delegate = MockControlDelegate()
        
        // Can't test "back" position because we're on a Macbook :)
        let subject = try? Camera(.front, controlDelegate: delegate)
        XCTAssertNotNil(subject)
        XCTAssertEqual(CameraPosition.front, subject?.position)
        
        // Ensure we get notified when it starts
        delegate.expectation = self.expectation(description: "The session started")
        subject?.start()
        self.wait(for: [delegate.expectation!], timeout: 2)
        
        delegate.expectation = self.expectation(description: "The session stopped")
        subject?.stop()
        self.wait(for: [delegate.expectation!], timeout: 2)
    }
    
    func test_obtaining_samples() {

        let mockReader = MockReader()
        let subject    = try? Camera(.front, reader: mockReader)
        XCTAssertNotNil(subject)
        
        mockReader.videoExpectation = self.expectation(description: "We should get at least one video sample")
        mockReader.audioExpectation = self.expectation(description: "We should get at least one audio sample")
        subject?.start()
        self.wait(for: [mockReader.videoExpectation!, mockReader.audioExpectation!], timeout: 12)
        subject?.stop()

    }
    
    static var allTests = [
        ("Test Basic Behavior", test_basic_object_behavior),
        ("Test obtaining samples", test_obtaining_samples)
    ]
}
