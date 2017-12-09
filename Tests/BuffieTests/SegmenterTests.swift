import XCTest
import CoreMedia
@testable import Buffie
//
//class SegmenterTests: XCTestCase {
//    
//    class MockDelegate: StreamSegmenterDelegate {
//        
//        var initExp: XCTestExpectation?
//        var newSegExp: XCTestExpectation?
//        var moofExp: XCTestExpectation?
//        
//        var config: MOOVConfig?
//        var segmentID: Int?
//        var sequenceNumber: Int?
//        var samples: [Sample] = []
//        
//        func writeInitSegment(with config: MOOVConfig) {
//            self.config = config
//            self.initExp?.fulfill()
//        }
//        
//        func createNewSegment(with segmentID: Int, and sequenceNumber: Int) {
//            self.segmentID      = segmentID
//            self.sequenceNumber = sequenceNumber
//            self.newSegExp?.fulfill()
//        }
//        
//        func writeMOOF(with samples: [Sample], and duration: Double) {
//            self.samples = samples
//            self.moofExp?.fulfill()
//        }
//    }
//
//    func test_that_we_are_ready_with_audio_and_video() {
//        /// Ensure we get marked as ready if we need both audio and video samples
//        let segmenter   = makeSegmenter(for: [.video, .audio])
//        let videoSample = makeVideoSample()
//        segmenter.append(videoSample)
//        XCTAssertFalse(segmenter.readyForMOOV)
//
//        let audioSample = makeAudioSample()
//        segmenter.append(audioSample)
//        XCTAssertTrue(segmenter.readyForMOOV)
//    }
//    
//    func test_that_we_are_ready_with_just_video() {
//        let segmenter    = makeSegmenter(for: [.video])
//        let videoSample  = makeVideoSample()
//        segmenter.append(videoSample)
//        XCTAssertTrue(segmenter.readyForMOOV)
//    }
//    
//    func test_that_we_are_ready_with_just_audio() {
//        let segmenter   = makeSegmenter(for: [.audio])
//        let audioSample = makeAudioSample()
//        segmenter.append(audioSample)
//        XCTAssertTrue(segmenter.readyForMOOV)
//    }
//    
//    func test_that_we_ignore_samples_we_are_not_interested_in() {
//        let segmenter   = makeSegmenter(for: [.video])
//        XCTAssertEqual(0, segmenter.videoSamples.count)
//        XCTAssertEqual(0, segmenter.audioSamples.count)
//
//        let videoSample = makeVideoSample()
//        let audioSample = makeAudioSample()
//        
//        segmenter.append(videoSample)
//        XCTAssertEqual(1, segmenter.videoSamples.count)
//        XCTAssertEqual(0, segmenter.audioSamples.count)
//
//        segmenter.append(audioSample)
//        XCTAssertEqual(1, segmenter.videoSamples.count)
//        XCTAssertEqual(0, segmenter.audioSamples.count)
//    }
//    
//    func test_that_we_get_an_init_segment_callback_for_video() {
//        
//        let delegate     = MockDelegate()
//        delegate.initExp = self.expectation(description: "Get notified when we can writer a init segment")
//        
//        let segmenter    = makeSegmenter(for: [.video], with: delegate)
//        let sample       = makeVideoSample()
//        segmenter.append(sample)
//        
//        self.wait(for: [delegate.initExp!], timeout: 1)
//    }
//    
//    func test_that_we_get_an_init_segment_callback_for_video_and_audio() {
//        let delegate     = MockDelegate()
//        delegate.initExp = self.expectation(description: "Get notified when we can writer a init segment")
//        
//        let segmenter    = makeSegmenter(for: [.video, .audio], with: delegate)
//        let vSample      = makeVideoSample()
//        let aSample      = makeAudioSample()
//        segmenter.append(vSample)
//        segmenter.append(aSample)
//        self.wait(for: [delegate.initExp!], timeout: 1)
//    }
//    
//    func test_that_we_get_a_make_new_segment_notification_for_video() {
//        let delegate       = MockDelegate()
//        delegate.initExp   = self.expectation(description: "Get notified when we can writer a init segment")
//        delegate.newSegExp = self.expectation(description: "Get notificed when we should create a new segment")
//
//        let segmenter    = makeSegmenter(for: [.video], with: delegate)
//        let sample       = makeVideoSample()
//        segmenter.append(sample)
//        self.wait(for: [delegate.initExp!, delegate.newSegExp!], timeout: 1)
//    }
//
//    func test_that_we_get_a_make_new_segment_notification_for_video_and_audio() {
//        let delegate     = MockDelegate()
//        let segmenter    = makeSegmenter(for: [.video, .audio], with: delegate)
//
//        ///// Ensure we timeout first
//        let timeoutDelegate        = TimeoutDelegate()
//        timeoutDelegate.timeoutExp = self.expectation(description: "Ensure we don't fulfill expectations yet")
//        
//        let vSample      = makeVideoSample()
//        segmenter.append(vSample)
//
//        let waiter          = XCTWaiter(delegate: timeoutDelegate)
//        delegate.initExp    = self.expectation(description: "[Init Segment] This should fail until we get video AND audio")
//        delegate.newSegExp  = self.expectation(description: "[Frag Segment] This should fail until we get video AND audio ")
//        waiter.wait(for: [delegate.initExp!, delegate.newSegExp!], timeout: 0.2)
//        
//        self.wait(for: [timeoutDelegate.timeoutExp!], timeout: 1)
//        XCTAssertEqual(2, timeoutDelegate.unfulfilled.count)
//        XCTAssertEqual(delegate.initExp, timeoutDelegate.unfulfilled.first)
//        XCTAssertEqual(delegate.newSegExp, timeoutDelegate.unfulfilled.last)
//
//        ///// Now append audio an make sure we work
//        let aSample         = makeAudioSample()
//        delegate.initExp    = self.expectation(description: "We should signal for an init segment")
//        delegate.newSegExp  = self.expectation(description: "We should signal for a new fragment segment")
//
//        segmenter.append(aSample)
//        self.wait(for: [delegate.initExp!, delegate.newSegExp!], timeout: 1)
//        
//        XCTAssertNotNil(delegate.config)
//        XCTAssertNotNil(delegate.config?.videoSettings)
//        XCTAssertNotNil(delegate.config?.audioSettings)
//        
//        XCTAssertEqual(1, delegate.segmentID)
//        XCTAssertEqual(1, delegate.sequenceNumber)
//    }
//    
//    func test_that_we_get_moof_notifications_for_video() {
//        let delegate     = MockDelegate()
//        let segmenter    = makeSegmenter(for: [.video], with: delegate)
//        
//        ///// Ensure we timeout first for JUST the moof.
//        let timeoutDelegate        = TimeoutDelegate()
//        let waiter                 = XCTWaiter(delegate: timeoutDelegate)
//        timeoutDelegate.timeoutExp = self.expectation(description: "Ensure we don't fulfill expectations yet")
//        delegate.initExp           = self.expectation(description: "We should signal for an init segment")
//        delegate.newSegExp         = self.expectation(description: "We should signal for a new fragment segment")
//        delegate.moofExp           = self.expectation(description: "[MOOF] This should fail until we have enough samples to populate the moof")
//        
//        let vSample = makeVideoSample(with: 2499, isSync: true)
//        segmenter.append(vSample)
//
//        waiter.wait(for: [delegate.initExp!, delegate.newSegExp!, delegate.moofExp!], timeout: 0.2)
//        self.wait(for: [timeoutDelegate.timeoutExp!], timeout: 1)
//        XCTAssertEqual(1, timeoutDelegate.unfulfilled.count)
//        XCTAssertEqual(delegate.moofExp, timeoutDelegate.unfulfilled.first)
//        
//        ///// Now ensure that we get a moof
//        delegate.moofExp = self.expectation(description: "We should signal that we need to write a moof")
//        segmenter.append(makeVideoSample(with: 2499, isSync: false))
//        segmenter.append(makeVideoSample(with: 2499, isSync: false))
//        segmenter.append(makeVideoSample(with: 2499, isSync: false))
//        segmenter.append(makeVideoSample(with: 2499, isSync: false))
//        segmenter.append(makeVideoSample(with: 2499, isSync: false))
//        let nextSync = makeVideoSample(with: 2499, isSync: true)
//        
//        segmenter.append(nextSync)
//        self.wait(for: [delegate.moofExp!], timeout: 1)
//        XCTAssertEqual(6, delegate.samples.count)
//    }
//    
//    func test_that_we_get_a_new_segment_callback_when_nearing_target_duration_with_video() {
//        let delegate     = MockDelegate()
//        let segmenter    = makeSegmenter(for: [.video], with: delegate)
//        
//        delegate.newSegExp = self.expectation(description: "Initial segment")
//        segmenter.append(makeVideoSample(with: 2499, isSync: true))
//        self.wait(for: [delegate.newSegExp!], timeout: 1)
//        
//        delegate.newSegExp = self.expectation(description: "The next segment")
//        for i in 1...120 {
//            if i % 30 == 0 { segmenter.append(makeVideoSample(with: 2499, isSync: true)) }
//            else { segmenter.append(makeVideoSample(with: 2499, isSync: false)) }
//        }
//        self.wait(for: [delegate.newSegExp!], timeout: 1)
//        XCTAssertEqual(2, delegate.segmentID)
//        XCTAssertEqual(4, delegate.sequenceNumber)
//        
//        XCTAssertEqual(30, delegate.samples.count)
//        XCTAssertTrue(delegate.samples.first!.isSync)
//    }
//    
//    func test_that_we_get_a_new_segment_callback_when_nearing_target_duration_with_audio_and_video() {
//        let delegate    = MockDelegate()
//        let segmenter   = makeSegmenter(for: [.video, .audio], with: delegate)
//
//        //// Wait for the initial segment to get signalled
//        delegate.newSegExp = self.expectation(description: "Initial segment")
//        segmenter.append(makeVideoSample(with: 2499, isSync: true))
//        segmenter.append(makeAudioSample(with: 1024))
//        self.wait(for: [delegate.newSegExp!], timeout: 1)
//        
//
//        //// Now wait for the next segment
//        delegate.newSegExp = self.expectation(description: "The next segment")
//    
//        let splitQ = DispatchQueue(label: "testQ",
//                                   qos: .default,
//                                   attributes: .concurrent,
//                                   autoreleaseFrequency: .inherit,
//                                   target: nil)
//        
//        DispatchQueue.main.async {
//            /// write a bunch of audio samples
//            splitQ.async { for _ in 0...2048 { segmenter.append(makeAudioSample(with: 1024)) } }
//
//            /// write a bunch of video samples
//            splitQ.async {
//                for i in 1...120 {
//                    if i % 30 == 0 { segmenter.append(makeVideoSample(with: 2499, isSync: true)) }
//                    else { segmenter.append(makeVideoSample(with: 2499, isSync: false)) }
//                }
//            }
//
//        }
//        
//        self.wait(for: [delegate.newSegExp!], timeout: 5)
//        XCTAssertEqual(2, delegate.segmentID)
//        XCTAssertEqual(4, delegate.sequenceNumber)
//
//        XCTAssertEqual(81, delegate.samples.count)
//        XCTAssertTrue(delegate.samples.first!.isSync)
//    }
//
//}
//
//class TimeoutDelegate: NSObject, XCTWaiterDelegate {
//    
//    var timeoutExp: XCTestExpectation?
//    var unfulfilled: [XCTestExpectation] = []
//    
//    func waiter(_ waiter: XCTWaiter, fulfillmentDidViolateOrderingConstraintsFor expectation: XCTestExpectation, requiredExpectation: XCTestExpectation) {
//    }
//    
//    func waiter(_ waiter: XCTWaiter, didFulfillInvertedExpectation expectation: XCTestExpectation) {
//    }
//    
//    func nestedWaiter(_ waiter: XCTWaiter, wasInterruptedByTimedOutWaiter outerWaiter: XCTWaiter) {
//    }
//    
//    func waiter(_ waiter: XCTWaiter, didTimeoutWithUnfulfilledExpectations unfulfilledExpectations: [XCTestExpectation]) {
//        self.unfulfilled = unfulfilledExpectations
//        self.timeoutExp?.fulfill()
//    }
//}
//
//////////////////// Helpers for test data
//struct MockVideoSample: Sample {
//    var type: SampleType
//    var data: [UInt8]
//    var size: UInt32
//    var duration: Int64
//    var decode: Double
//    var timescale: UInt32
//    var format: MediaFormat
//    var isSync: Bool
//}
//
//struct MockAudioSample: Sample {
//    var type: SampleType
//    var data: [UInt8]
//    var size: UInt32
//    var duration: Int64
//    var decode: Double
//    var timescale: UInt32
//    var format: MediaFormat
//    var isSync: Bool
//}
//
//func makeSegmenter(for streamType: StreamType, with delegate: StreamSegmenterDelegate? = nil) -> StreamSegmenter {
//    let url       = URL(fileURLWithPath: "/tmp", isDirectory: true)
//    let segmenter = try? StreamSegmenter(outputDir: url,
//                                         targetSegmentDuration: 6,
//                                         streamType: streamType,
//                                         delegate: delegate)
//    
//    XCTAssertNotNil(segmenter)
//    
//    XCTAssertEqual(6, segmenter?.targetSegmentDuration)
//    XCTAssertFalse(segmenter!.readyForMOOV)
//    
//    return segmenter!
//}
//
//
//func makeVideoSample(with duration: Int64 = 0, isSync: Bool = false) -> MockVideoSample {
//    var vFormat: CMFormatDescription?
//    CMFormatDescriptionCreate(kCFAllocatorDefault, kCMMediaType_Video, fourCharCode(from: "avc1"), nil, &vFormat)
//    let videoSample = MockVideoSample(type: .video,
//                                      data: [],
//                                      size: 0,
//                                      duration: duration,
//                                      decode: 0,
//                                      timescale: 30000,
//                                      format: vFormat!,
//                                      isSync: isSync)
//    return videoSample
//}
//
//func makeAudioSample(with duration: Int64 = 0) -> MockAudioSample {
//    var aFormat               = AudioStreamBasicDescription()
//    aFormat.mChannelsPerFrame = 2
//    aFormat.mSampleRate       = 44100
//    let audioSample           = MockAudioSample(type: .audio,
//                                                data: [],
//                                                size: 0,
//                                                duration: duration,
//                                                decode: 0,
//                                                timescale: 44100,
//                                                format: aFormat,
//                                                isSync: false)
//    return audioSample
//}
//
//
