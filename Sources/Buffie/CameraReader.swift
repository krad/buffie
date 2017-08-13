import Foundation
import AVKit

public protocol CameraReaderProtocol {
    var videoReader: AVCaptureVideoDataOutputSampleBufferDelegate { get }
    var audioReader: AVCaptureAudioDataOutputSampleBufferDelegate { get }
}

internal protocol SampleReader {
    func got(_ sample: CMSampleBuffer, type: SampleType)
}

public enum SampleType: UInt8 {
    case video = 0x75 // v
    case audio = 0x61 // a
}

public class CameraReader: CameraReaderProtocol, SampleReader {
    
    public var videoReader: AVCaptureVideoDataOutputSampleBufferDelegate
    public var audioReader: AVCaptureAudioDataOutputSampleBufferDelegate
    
    init() {
        let videoReader = VideoSampleReader()
        let audioReader = AudioSampleReader()
        
        self.videoReader = videoReader
        self.audioReader = audioReader
        
        videoReader.delegate = self
        audioReader.delegate = self
    }
    
    open func got(_ sample: CMSampleBuffer, type: SampleType) {
        print(#function, type)
    }
    
}

internal class VideoSampleReader: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    internal var delegate: SampleReader?
    
    internal func captureOutput(_ output: AVCaptureOutput,
                                didOutput sampleBuffer: CMSampleBuffer,
                                from connection: AVCaptureConnection)
    {
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
