import XCTest
import CoreMedia
@testable import Buffie

@available(OSX 10.11, iOS 5, *)
class AVDemuxerTests: XCTestCase {
    
    class MockDemuxerDelegate: AVDemuxerDelegate {
        
        var expectation: XCTestExpectation?
        
        func demuxed(sample: CMSampleBuffer, type: SampleType) {
            self.expectation?.fulfill()
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

//        demuxDelegate.expectation = self.expectation(description: "demuxing samples")
//        camera?.start()
//        self.wait(for: [demuxDelegate.expectation!], timeout: 2)

        let x = [0, 0, 0, 1, 112, 0, 0, 0, 34, 39, 66, 0, 40, 137, 139, 96, 240, 40, 216, 9, 224, 0, 4, 226, 0, 0, 244, 36, 28, 12, 0, 23, 112, 0, 5, 220, 23, 189, 240, 124, 34, 17, 184, 0, 0, 0, 1, 112, 0, 0, 0, 4, 40, 206, 31, 32, 0]

        
        
        
    }
    
    static var allTests = [
        ("Test Demuxing Audio and Video", test_that_we_can_demux_samples),
    ]
}
