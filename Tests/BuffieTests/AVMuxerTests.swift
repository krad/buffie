import XCTest
@testable import Buffie

@available(OSX 10.11, iOS 5, *)
class AVMuxerTests: XCTestCase {
    
    func test_muxing_audio_and_video() {
        
        let delegate = MockMuxerDelegate()
        let muxer    = try? AVMuxer(delegate: delegate)
        XCTAssertNotNil(muxer)
        
        let camera = try? Camera(.back, reader: muxer!, controlDelegate: nil)
        XCTAssertNotNil(camera)
        
        delegate.audioExpectation = self.expectation(description: "Getting an audio packet")
        delegate.videoExpectation = self.expectation(description: "Getting a video packet")
        camera?.start()
        self.wait(for: [delegate.audioExpectation!, delegate.videoExpectation!], timeout: 4)
                
    }
    
    static var allTests = [
        ("Test Muxing Audio and Video", test_muxing_audio_and_video),
    ]
    
}
