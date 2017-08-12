import XCTest
import CoreMedia
@testable import Buffie

class EncoderDelegate: VideoEncoderDelegate {
    
    var expectation: XCTestExpectation?
    var encodedSample: CMSampleBuffer?
    
    func encoded(videoSample: CMSampleBuffer) {
        self.encodedSample = videoSample
        self.expectation?.fulfill()
    }
}

class DecoderDelegate: VideoDecoderDelegate {
    
    var expectation: XCTestExpectation?
    var decodedSample: CVPixelBuffer?
    
    override func decoded(_ data: (CVPixelBuffer, CMTime)) {
        self.decodedSample = data.0
        self.expectation?.fulfill()
    }
}

class MockAudioEncoderDelegate: AudioEncoderDelegate {
    
    var expectation: XCTestExpectation?
    
    func encoded(audioSample: AudioBufferList) {
        self.expectation?.fulfill()
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
