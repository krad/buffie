import XCTest
import CoreMedia
import AVKit
@testable import Buffie

@available(OSX 10.11, iOS 5, *)
class AudioEncoderTests: XCTestCase {
    
    func test_basic_object_behavior() {
        
        let settings     = AudioEncoderSettings()
        let mockDelegate = MockAudioEncoderDelegate()
        let subject      = try? AudioEncoder(settings, delegate: mockDelegate)
        
        let wavURL = URL(fileURLWithPath: "\(fixturesPath)/1000.wav")
        XCTAssertNotNil(wavURL)
        
        let audioFile = try? AVAudioFile(forReading: wavURL)
        XCTAssertNotNil(audioFile)

        let pcmBuffer = AVAudioPCMBuffer(pcmFormat: audioFile!.processingFormat, frameCapacity: UInt32(audioFile!.length))
        XCTAssertNotNil(pcmBuffer)
        
        try? audioFile?.read(into: pcmBuffer!)
        XCTAssertNotNil(pcmBuffer)
        XCTAssertEqual(pcmBuffer?.frameLength, 440999)
        
        let sampleBuffer = pcmBuffer?.toCMSampleBuffer()
        XCTAssertNotNil(sampleBuffer)
        
        mockDelegate.expectation = self.expectation(description: "Converting a sample to AAC")
        subject?.encode(sampleBuffer!)
        self.wait(for: [mockDelegate.expectation!], timeout: 2)
        
    }

    static var allTests = [
        ("Test Basic Behavior", test_basic_object_behavior),
    ]
    
}
