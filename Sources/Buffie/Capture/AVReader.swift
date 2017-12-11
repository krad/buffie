import Foundation
import AVKit

public protocol AVReaderProtocol {
    var videoReader: AVCaptureVideoDataOutputSampleBufferDelegate { get }
    var audioReader: AVCaptureAudioDataOutputSampleBufferDelegate { get }
}

internal protocol SampleReader {
    func got(_ sample: CMSampleBuffer, type: SampleType)
}

public enum SampleType: UInt8 {
    case video    = 0x75 // v
    case audio    = 0x61 // a
}

open class AVReader: AVReaderProtocol, SampleReader {
    
    final public var videoReader: AVCaptureVideoDataOutputSampleBufferDelegate
    final public var audioReader: AVCaptureAudioDataOutputSampleBufferDelegate
    
    final public var videoFormat: CMFormatDescription?
    final public var audioFormat: CMFormatDescription?
    
    public init() {
        let videoReader = VideoSampleReader()
        let audioReader = AudioSampleReader()
        
        self.videoReader = videoReader
        self.audioReader = audioReader
        
        videoReader.delegate = self
        audioReader.delegate = self
    }
    
    open func got(_ sample: CMSampleBuffer, type: SampleType) {
        switch type {
        case .video: self.videoFormat = getFormatDescription(sample)
        case .audio: self.audioFormat = getFormatDescription(sample)
        }
    }
    
}

internal class VideoSampleReader: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    internal var delegate: SampleReader?
    internal var previousPTS = kCMTimeZero
    
    internal func captureOutput(_ output: AVCaptureOutput,
                                didOutput sampleBuffer: CMSampleBuffer,
                                from connection: AVCaptureConnection)
    {
        let pts      = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        var duration = CMSampleBufferGetDuration(sampleBuffer)
        
        if duration.value <= 0 {
            
            duration = CMTimeSubtract(pts, self.previousPTS)
            print(duration)
            self.previousPTS = pts
            
            var newSampleBuffer: CMSampleBuffer?
            var timingInfo = CMSampleTimingInfo(duration: duration, presentationTimeStamp: pts, decodeTimeStamp: kCMTimeInvalid)
            let status = CMSampleBufferCreateCopyWithNewTiming(kCFAllocatorDefault, sampleBuffer, 1, &timingInfo, &newSampleBuffer)
            
            if status != noErr {
                print("Problem updating sample buffer timing info:", status)
            } else {
                self.delegate?.got(newSampleBuffer!, type: .video)
                return
            }
        }
        
        self.delegate?.got(sampleBuffer, type: .video)
    }
    
}

internal class AudioSampleReader: NSObject, AVCaptureAudioDataOutputSampleBufferDelegate {
    
    internal var delegate: SampleReader?
    
    internal func captureOutput(_ output: AVCaptureOutput,
                                didOutput sampleBuffer: CMSampleBuffer,
                                from connection: AVCaptureConnection)
    {
        self.delegate?.got(sampleBuffer, type: .audio)
    }
}
