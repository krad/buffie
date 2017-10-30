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
    
    func decoded(_ pixelBuffer: CVPixelBuffer, with pts: CMTime) {
        self.decodedSample = pixelBuffer
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

class MockMuxerDelegate: AVMuxerDelegate {
    
    var audioExpectation: XCTestExpectation?
    var videoExpectation: XCTestExpectation?
    
    var paramSetExpectation: XCTestExpectation?
    
    var audioCount = 0
    var videoCount = 0
    
    func got(paramSet: [[UInt8]]) {
        self.paramSetExpectation?.fulfill()
    }
    
    func muxed(data: [UInt8]) {
        if data[4] == SampleType.audio.rawValue {
            self.audioCount += 1
            if self.audioCount == 1 {
                self.audioExpectation?.fulfill()
            }
        }
        
        if data[4] == SampleType.video.rawValue {
            self.videoCount += 1
            if self.videoCount == 1 {
                self.videoExpectation?.fulfill()
            }
        }
    }
    
}

class MockMuxerDelegateRedirect: AVMuxerDelegate {
    
    var delegate: AVDemuxer?
    
    func got(paramSet: [[UInt8]]) {
        
        self.delegate?.got(sampleFormatData: paramSet)
    }
    
    func muxed(data: [UInt8]) {
        self.delegate?.demux(data)
    }
    
}
