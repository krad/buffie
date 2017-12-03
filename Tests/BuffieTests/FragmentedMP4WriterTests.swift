import XCTest
import AVFoundation
@testable import Buffie

class FragmentedMP4WriterTests: XCTestCase {
    
    class SimpleReader: AVReader {
        var callback: (CMSampleBuffer, SampleType) -> Void
        init(callback: @escaping (CMSampleBuffer, SampleType) -> Void) {
            self.callback = callback
        }
        
        override func got(_ sample: CMSampleBuffer, type: SampleType) {
            super.got(sample, type: type)
            self.callback(sample, type)
        }
    }

    
//    func test_that_we_only_accept_directories() {
//
//        let file = URL(fileURLWithPath: "/tmp/file.mp4")
//        XCTAssertThrowsError(try FragmentedMP4Writer(file))
//
//        let dir = URL(fileURLWithPath: "/tmp")
//        XCTAssertNoThrow(try FragmentedMP4Writer(dir))
//
//        let badDir = URL(fileURLWithPath: "/blahblahblahallbalha")
//        XCTAssertThrowsError(try FragmentedMP4Writer(badDir))
//
//    }
    
//    func test_segment_naming_conventions() {
//        let dir    = URL(fileURLWithPath: "/tmp")
//        let writer = try? FragmentedMP4Writer(dir)
//        XCTAssertNotNil(writer)
//        XCTAssertEqual(writer?.currentSegmentName, "fileSeq0.mp4")
//    }
    
    func test_that_we_can_parse_nalus_from_byte_array() {
        let iterator = NALUStreamIterator(streamBytes: compressedFrame, currentIdx: 0)
        
        var results: [NALU] = []
        
        for nalu in iterator {
            results.append(nalu)
        }
        
        XCTAssertEqual(1, results.count)
        
        // Data contains the entire NALU.
        XCTAssertEqual(Int(results.first!.data.count), compressedFrame.count)
        
        // Size is the first 4 bytes of the NALU the describes how large the payload is
        XCTAssertEqual(Int(results.first!.payloadSize), compressedFrame.count-4)
    }
    
    func xtest_experiment() {
        let dir    = URL(fileURLWithPath: "/tmp")
        let writer = try? FragmentedMP4Writer(dir)
        XCTAssertNotNil(writer)

        let reader = SimpleReader() { sample, type in writer?.got(sample, type: type) }
        let camera = try? Camera(.back, reader: reader, controlDelegate: nil)
//        let camera = try? Camera(videoDeviceID: "DJH4314BF2VF6VTDF",
//                                 audioDeviceID: "AppleUSBAudioEngine:ZOOM Corporation:H6:000000000000:2,1",
//                                 reader: reader,
//                                 controlDelegate: nil)
        
        XCTAssertNotNil(camera)
        camera?.start()
        let e = self.expectation(description: "Blah")
        self.wait(for: [e], timeout: 20)
        
        writer?.end()
    }
    
}
