import Foundation
import AVFoundation

public class MP4Writer {
    
    private var writer: AVAssetWriter
    private var videoInput: AVAssetWriterInput
    private var pixelAdaptor: AVAssetWriterInputPixelBufferAdaptor
    internal var timescale: CMTimeScale = 600
    
    init(_ fileURL: URL, formatDescription: CMFormatDescription) throws {
        
        self.writer = try AVAssetWriter(outputURL: fileURL, fileType: .mp4)
        
        let videoSettings: [String: Any] = [AVVideoCodecKey: AVVideoCodecH264,
                                            AVVideoWidthKey: NSNumber(value: 640),
                                            AVVideoHeightKey: NSNumber(value: 480)]
        
        self.videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings, sourceFormatHint: formatDescription)
        
        self.videoInput.expectsMediaDataInRealTime           = true
        self.videoInput.performsMultiPassEncodingIfSupported = true
        self.videoInput.mediaTimeScale                       = timescale
        
        let pixelAttrs    = [kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA)]
        self.pixelAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: self.videoInput,
                                                                 sourcePixelBufferAttributes: pixelAttrs)
        
        self.writer.add(self.videoInput)
        
    }
    
    func start(at time: CMTime) {
        if self.writer.startWriting() {
            writer.startSession(atSourceTime: time)
        }
    }
    
    func stop(at time: CMTime) {
        self.videoInput.markAsFinished()
        self.writer.endSession(atSourceTime: time)
        self.writer.finishWriting {
            print(#function, "Finished Writing")
        }
    }
    
    func write(_ pixelBuffer: CVPixelBuffer, with pts: CMTime) {
        if self.writer.status != .unknown {
            if self.videoInput.isReadyForMoreMediaData {
                self.pixelAdaptor.append(pixelBuffer, withPresentationTime: pts)
            }
        }
    }
    
}
