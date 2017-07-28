import XCTest
@testable import Buffie

class CameraTests: XCTestCase {
    
    class MockControlDelegate: CameraControlDelegate {
        
        var expectation: XCTestExpectation?
        
        func cameraStarted() {
            self.expectation?.fulfill()
        }
        
        func cameraStopped() {
            self.expectation?.fulfill()
        }
        
        func cameraInteruppted() {
            
        }
    }
    
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
    
    static var allTests = [
        ("testExample", test_basic_object_behavior),
    ]
}
