import XCTest
import CoreMedia
import AVKit
@testable import Buffie

//@available(OSX 10.11, iOS 5, *)
//class AudioDecoderTests: XCTestCase {
//
//    func test_basic_object_behavior() {
//        
//        //// Setup an encoder to produce samples
//        let encSettings = AudioEncoderDecoderSettings(.encoding)
//        let encDelegate = MockAudioEncoderDelegate()
//        let encoder     = try? AudioEncoder(encSettings, delegate: encDelegate)
//        
//        let sampleBuffer = audioSampleFromFixture()
//        encDelegate.expectation = self.expectation(description: "Encode a sample to AAC")
//        encoder?.encode(sampleBuffer)
//        self.wait(for: [encDelegate.expectation!], timeout: 2)
//        XCTAssertNotNil(encDelegate.lastBuffer)
//        
//        let audioBufferBytes = bytes(from: encDelegate.lastBuffer!)
//        XCTAssertNotNil(audioBufferBytes)
//        XCTAssert(audioBufferBytes!.count > 0)
//        
//        //// Now setup the decoder
//        let settings     = AudioEncoderDecoderSettings(.decoding)
//        let mockDelegate = MockAudioDecoderDelegate()
//        let subject      = try? AudioDecoder(settings, delegate: mockDelegate)
//        XCTAssertNotNil(subject)
//        
//        mockDelegate.expectation = self.expectation(description: "Converting bytes to an AudioBufferList")
//        subject?.decode(audioBufferBytes!)
//        self.wait(for: [mockDelegate.expectation!], timeout: 2)
//        
//    }
//    
//    static var allTests = [
//        ("Test Basic Behavior", test_basic_object_behavior),
//    ]
//    
//}

