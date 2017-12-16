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
    internal var samples = ThreadSafeArray<CMSampleBuffer>()
    
    var previousTimeStamp: CFAbsoluteTime?
    
    internal func captureOutput(_ output: AVCaptureOutput,
                                didOutput sampleBuffer: CMSampleBuffer,
                                from connection: AVCaptureConnection)
    {
        let duration = CMSampleBufferGetDuration(sampleBuffer)
        
        /// iOS sets all the duration timestamps to 0.
        /// This means we have to calculate them.
        if duration.value <= 0 {
            self.recalculateDuration(for: sampleBuffer)
            return
        }
        
        self.delegate?.got(sampleBuffer, type: .video)
    }
    
    private func recalculateDuration(for sampleBuffer: CMSampleBuffer) {
        if let prevSampleBuffer = self.samples.last {
            
            let prevPTS  = CMSampleBufferGetPresentationTimeStamp(prevSampleBuffer)
            let currPTS  = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            let duration = CMTimeSubtract(currPTS, prevPTS)
            
//            let thisFrameWallClock  = CFAbsoluteTimeGetCurrent()
//            print(thisFrameWallClock)
//            let elapsedTime         = thisFrameWallClock - prevTimeStamp
//            let duration            = CMTimeMake(Int64(elapsedTime * (30*1000)), 30*1000)
//            print(duration)
            
            if let newSample = self.createNewSample(from: prevSampleBuffer, with: duration, and: currPTS) {
                self.delegate?.got(newSample, type: .video)
                self.samples.removeLast()
                self.samples.append(sampleBuffer)
            }
            
        } else {
            self.previousTimeStamp = CFAbsoluteTimeGetCurrent()
            self.samples.append(sampleBuffer)
        }
    }
    
    private func createNewSample(from sampleBuffer: CMSampleBuffer,
                                 with duration: CMTime,
                                 and pts: CMTime) -> CMSampleBuffer?
    {
        var newSampleBuffer: CMSampleBuffer?
        var timingInfo = CMSampleTimingInfo(duration: duration,
                                            presentationTimeStamp: pts,
                                            decodeTimeStamp: kCMTimeInvalid)
        
        let status = CMSampleBufferCreateCopyWithNewTiming(kCFAllocatorDefault,
                                                           sampleBuffer,
                                                           1,
                                                           &timingInfo,
                                                           &newSampleBuffer)
        
        if status != noErr {
            print("Problem updating sample buffer timing info:", status)
        }
        return newSampleBuffer
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
