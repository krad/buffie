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
        
        let fpsOutput: Int64 = 24; //Some possible values: 30, 10, 15 24, 25, 30/1.001 or 29.97;
        let cmTimeSecondsDenominatorTimescale: Int32 = 600 * 100000; //To more precisely handle 29.97.
        let cmTimeNumeratorValue: Int64 = Int64(cmTimeSecondsDenominatorTimescale) / fpsOutput;
        let pts = CMTimeMake( videoFramesWrote * cmTimeNumeratorValue, cmTimeSecondsDenominatorTimescale);

        self.stop(at: pts, onComplete)
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
            
            let fpsOutput: Int64 = 24; //Some possible values: 30, 10, 15 24, 25, 30/1.001 or 29.97;
            let cmTimeSecondsDenominatorTimescale: Int32 = 600 * 100000; //To more precisely handle 29.97.
            let cmTimeNumeratorValue: Int64 = Int64(cmTimeSecondsDenominatorTimescale) / fpsOutput;
            let pts = CMTimeMake( videoFramesWrote * cmTimeNumeratorValue, cmTimeSecondsDenominatorTimescale);

            self.write(pixelBuffer, with: pts)
        }
    }
    
}
