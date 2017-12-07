import XCTest
import CoreMedia
@testable import Buffie

class AVDemuxerTests: XCTestCase {
    
    class MockStreamDelegate: AVMuxedStreamDelegate {
        var demuxer: AVDemuxer?
        
        func packetized(payload: [UInt8]) {
            self.demuxer?.received(bytes: payload)
        }
    }
    
    class MockDemuxerDelegate: AVDemuxerDelegate {
        
        var sampleExpectation: XCTestExpectation?
        var paramsExpectation: XCTestExpectation?
        
        func got(sampleFormatData: [[UInt8]]) {
            self.paramsExpectation?.fulfill()
        }
        
        func got(sample: [UInt8], sampleType: SampleType) {
            self.sampleExpectation?.fulfill()
        }
    }
    
    func test_that_we_can_demux_samples() {
        
        let streamDelegate      = MockStreamDelegate()
        let muxStreamBuilder    = AVMuxedStreamBuilder(delegate: streamDelegate)
        let muxer               = try? AVMuxer(delegate: muxStreamBuilder)
        XCTAssertNotNil(muxer)

        let demuxerDelegate     = MockDemuxerDelegate()
        let demuxer             = AVDemuxer(delegate: demuxerDelegate)
        streamDelegate.demuxer  = demuxer

        demuxerDelegate.paramsExpectation = self.expectation(description: "Ensure we demux params set")
        demuxerDelegate.sampleExpectation = self.expectation(description: "Ensure we get a video sample")
        demuxerDelegate.sampleExpectation?.assertForOverFulfill = false


        let camera = try? Camera(.back, reader: muxer!, controlDelegate: nil)
        XCTAssertNotNil(camera)
        camera?.start()
        
        self.wait(for: [demuxerDelegate.paramsExpectation!,
                        demuxerDelegate.sampleExpectation!], timeout: 2)
        
        camera?.stop()
    }
    
    static var allTests = [
        ("Test Demuxing Audio and Video", test_that_we_can_demux_samples),
    ]
}

