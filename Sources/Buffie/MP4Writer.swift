import Foundation
import AVFoundation

public class MP4Writer {
    
    private var writer: AVAssetWriter
    private var videoInput: AVAssetWriterInput
    private var pixelAdaptor: AVAssetWriterInputPixelBufferAdaptor
    private var videoFramesWrote: Int64 = 0
    
    public init(_ fileURL: URL, formatDescription: CMFormatDescription) throws {
        
        self.writer = try AVAssetWriter(outputURL: fileURL, fileType: .mp4)
        
        let videoSettings: [String: Any] = [AVVideoCodecKey: AVVideoCodecH264,
                                            AVVideoWidthKey: NSNumber(value: 640),
                                            AVVideoHeightKey: NSNumber(value: 480)]
        
        self.videoInput = AVAssetWriterInput(mediaType: .video,
                                             outputSettings: videoSettings,
                                             sourceFormatHint: formatDescription)
        
        self.videoInput.expectsMediaDataInRealTime           = true
        self.videoInput.performsMultiPassEncodingIfSupported = true
        
        let frameDuration              = CMTimeCodeFormatDescriptionGetFrameDuration(formatDescription)
        self.videoInput.mediaTimeScale = frameDuration.timescale
        
        let pixelAttrs    = [kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA)]
        self.pixelAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: self.videoInput,
                                                                 sourcePixelBufferAttributes: pixelAttrs)
        
        self.writer.add(self.videoInput)
    }
    
    public func start() {
        self.start(at: kCMTimeZero)
    }
    
    public func start(at time: CMTime) {
        if self.writer.startWriting() {
            writer.startSession(atSourceTime: time)
        }
    }
    
    public func stop(_ onComplete: (() -> (Void))?) {
        self.stop(at: CMTimeMake(self.videoFramesWrote - 1, self.videoInput.mediaTimeScale), onComplete)
    }
    
    public func stop(at time: CMTime) {
        self.stop(at: time, nil)
    }
    
    public func stop(at time: CMTime, _ onComplete: (() -> (Void))?) {
        self.videoInput.markAsFinished()
        self.writer.endSession(atSourceTime: time)
        self.writer.finishWriting {
            onComplete?()
        }
    }
    
    public func write(_ pixelBuffer: CVPixelBuffer, with pts: CMTime) {
        if self.writer.status != .unknown {
            if self.videoInput.isReadyForMoreMediaData {
                self.pixelAdaptor.append(pixelBuffer, withPresentationTime: pts)
                self.videoFramesWrote += 1
            }
        }
    }
    
    public func write(_ sample: CMSampleBuffer) {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sample) {
            let pts = CMSampleBufferGetPresentationTimeStamp(sample)
            self.write(pixelBuffer, with: pts)
        }
    }
    
}
