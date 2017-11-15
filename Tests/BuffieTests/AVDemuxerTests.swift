import XCTest
import CoreMedia
@testable import Buffie

//@available(OSX 10.11, iOS 5, *)
//class AVDemuxerTests: XCTestCase {
//    
//    class MockDemuxerDelegate: AVDemuxerDelegate {
//        
//        var videoExpectation: XCTestExpectation?
//        var audioExpectation: XCTestExpectation?
//        
//        func demuxed(sample: CVPixelBuffer, with pts: CMTime) {
//            self.videoExpectation?.fulfill()
//        }
//        
//        func demuxed(audioBufferList: AudioBufferList) {
//            self.audioExpectation?.fulfill()
//        }
//        
//    }
//    
//    func test_that_we_can_demux_samples() {
//        
//        let muxDelegate = MockMuxerDelegateRedirect()
//        let muxer    = try? AVMuxer(delegate: muxDelegate)
//        XCTAssertNotNil(muxer)
//        
//        let camera = try? Camera(.back, reader: muxer!, controlDelegate: nil)
//        XCTAssertNotNil(camera)
//        
//        let demuxDelegate = MockDemuxerDelegate()
//        let demuxer       = try? AVDemuxer(delegate: demuxDelegate)
//        XCTAssertNotNil(demuxer)
//        
//        muxDelegate.delegate = demuxer // Connect to muxer delegate directly to the demuxer
//
//        demuxDelegate.videoExpectation = self.expectation(description: "demuxing video samples")
//        demuxDelegate.videoExpectation?.assertForOverFulfill = false
//        
//        demuxDelegate.audioExpectation = self.expectation(description: "demuxing audio samples")
//        demuxDelegate.audioExpectation?.assertForOverFulfill = false
//        
//        camera?.start()
//        
//        self.wait(for: [demuxDelegate.videoExpectation!,
//                        demuxDelegate.audioExpectation!],
//                  timeout: 2)
//        
//    }
//    
//    static var allTests = [
//        ("Test Demuxing Audio and Video", test_that_we_can_demux_samples),
//    ]
//}

