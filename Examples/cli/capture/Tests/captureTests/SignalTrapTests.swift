import XCTest
import Darwin
@testable import captureCore

class SignalTrapTests: XCTestCase {

    func test_that_we_can_detect_a_sigint() {
        
        let trap = SignalTrap(SIGINT)
        
        XCTAssertFalse(trap.caughtSignal)
        raise(SIGINT)
        
        XCTAssertTrue(trap.caughtSignal)
    }
    
}
