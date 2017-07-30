import XCTest
import CoreMedia
import AVKit
@testable import Buffie

class AudioEncoderTests: XCTestCase {
    

    func test_basic_object_behavior() {
        
        let settings     = AudioEncoderSettings()
        let mockDelegate = AudioEncoderDelegate()
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
        
    }

    
    static var allTests = [
        ("Test Basic Behavior", test_basic_object_behavior),
    ]
    
}

extension AVAudioPCMBuffer {
    
    func toCMSampleBuffer() -> CMSampleBuffer? {
        
        var format: CMFormatDescription? = nil
        
        var status = noErr
        status = CMAudioFormatDescriptionCreate(kCFAllocatorDefault, self.format.streamDescription, 0, nil, 0, nil, nil, &format)
        if status != noErr {
            return nil
        }
        
        var timing = CMSampleTimingInfo(duration: CMTime(value: 1, timescale: Int32(self.format.streamDescription.pointee.mSampleRate)),
                                        presentationTimeStamp: kCMTimeZero,
                                        decodeTimeStamp: kCMTimeInvalid)
        
        var buffer: CMSampleBuffer? = nil
        status = CMSampleBufferCreate(kCFAllocatorDefault, nil, false, nil, nil, format, Int(self.frameLength), 1, &timing, 0, nil, &buffer)
        if status != noErr {
            return nil
        }
        
        status = CMSampleBufferSetDataBufferFromAudioBufferList(buffer!, kCFAllocatorDefault, kCFAllocatorDefault, 0, self.mutableAudioBufferList)
        if status != noErr {
            return nil
        }
        
        return buffer
        
    }
    
}
