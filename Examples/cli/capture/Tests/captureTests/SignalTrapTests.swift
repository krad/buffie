import XCTest
import Darwin
@testable import captureCore

class SignalTrapTests: XCTestCase {

    func xtest_that_we_can_detect_a_sigint() {
        let e = self.expectation(description: "Catching a signal")
        _ = SignalTrap(SIGINT) {
            e.fulfill()
        }
        
        raise(SIGINT)
        
        self.wait(for: [e], timeout: 3)
    }
    
}
