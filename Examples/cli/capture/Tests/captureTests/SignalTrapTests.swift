import XCTest
import Darwin
@testable import captureCore

class SignalTrapTests: XCTestCase {

    func test_that_we_can_detect_a_sigint() {
        
        let e = self.expectation(description: "Signal Callback")
        let trap = SignalTrap(SIGINT) {
            e.fulfill()
        }
        
        XCTAssertFalse(trap.caughtSignal)
        raise(SIGINT)
        
        self.wait(for: [e], timeout: 2)
        XCTAssertTrue(trap.caughtSignal)
    }
    
}
