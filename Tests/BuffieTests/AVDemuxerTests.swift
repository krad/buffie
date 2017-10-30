import XCTest
import CoreMedia
@testable import Buffie
import BoyerMoore

@available(OSX 10.11, iOS 5, *)
class AVDemuxerTests: XCTestCase {
    
    class MockDemuxerDelegate: AVDemuxerDelegate {
        
        var videoExpectation: XCTestExpectation?
        
        func demuxed(sample: CVPixelBuffer, with pts: CMTime) {
            self.videoExpectation?.fulfill()
        }
    }
    
    func test_that_we_can_demux_samples() {
        
        let muxDelegate = MockMuxerDelegateRedirect()
        let muxer    = try? AVMuxer(delegate: muxDelegate)
        XCTAssertNotNil(muxer)
        
        let camera = try? Camera(.back, reader: muxer!, controlDelegate: nil)
        XCTAssertNotNil(camera)
        
        let demuxDelegate = MockDemuxerDelegate()
        let demuxer       = AVDemuxer(delegate: demuxDelegate)
        
        muxDelegate.delegate = demuxer // Connect to muxer delegate directly to the demuxer

        demuxDelegate.videoExpectation = self.expectation(description: "demuxing samples")
        demuxDelegate.videoExpectation?.assertForOverFulfill = false
        camera?.start()
        self.wait(for: [demuxDelegate.videoExpectation!], timeout: 2)
        
    }
    
    static var allTests = [
        ("Test Demuxing Audio and Video", test_that_we_can_demux_samples),
    ]
}
