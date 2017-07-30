import XCTest
import CoreMedia
@testable import Buffie

class EncoderDelegate: VideoEncoderDelegate {
    
    var expectation: XCTestExpectation?
    var encodedSample: CMSampleBuffer?
    
    func encoded(_ sample: CMSampleBuffer) {
        self.encodedSample = sample
        self.expectation?.fulfill()
    }
}

class DecoderDelegate: VideoDecoderDelegateProtocol {
    
    var expectation: XCTestExpectation?
    var decodedSample: CVPixelBuffer?
    
    func decoded(pixelBuffer: CVPixelBuffer, with pts: CMTime) {
        self.decodedSample = pixelBuffer
        self.expectation?.fulfill()
    }
}

class AudioEncoderDelegate: AudioEncoderDelegateProtocol {
    
    func encoded(_ sample: CMSampleBuffer) {
        
    }
    
}


class MockControlDelegate: CameraControlDelegate {
    
    var expectation: XCTestExpectation?
    
    func cameraStarted() {
        self.expectation?.fulfill()
    }
    
    func cameraStopped() {
        self.expectation?.fulfill()
    }
    
    func cameraInteruppted() {
        
    }

}

class MockReader: CameraReader {
    
    var videoExpectation: XCTestExpectation?
    var videoFulfillCount = 0
    
    var audioExpectation: XCTestExpectation?
    var audioFulfillCount = 0
    
    override func got(_ sample: CMSampleBuffer, type: SampleType) {
        if type == .video {
            if self.videoFulfillCount == 0 {
                self.videoFulfillCount = 1
                self.videoExpectation?.fulfill()
            }
        }
        
        if type == .audio {
            if self.audioFulfillCount == 0 {
                self.audioFulfillCount = 1
                self.audioExpectation?.fulfill()
            }
        }
    }
    
}
