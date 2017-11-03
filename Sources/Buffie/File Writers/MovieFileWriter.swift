import Foundation
import AVFoundation

public struct MovieFileConfig {
    var url: URL
    var container: MovieFileContainer = .mp4
    var quality: MovieFileQuality = .high
    var videoBitRate: Int?
    var videoFormat: CMFormatDescription
    var audioFormat: CMFormatDescription?
}

public enum MovieFileContainer: String {
    case mp4 = "mp4"
    case m4v = "m4v"
    case mov = "mov"
    
    internal var fileType: AVFileType {
        switch self {
        case .mp4: return AVFileType.mp4
        case .m4v: return AVFileType.m4v
        case .mov: return AVFileType.mov
        }
    }
}

public enum MovieFileQuality: String {
    case low    = "low"
    case medium = "medium"
    case high   = "high"
    
    internal var settingsAssitant: AVOutputSettingsAssistant {
        switch self {
        case .high: return AVOutputSettingsAssistant(preset: .preset3840x2160)!
        case .medium: return AVOutputSettingsAssistant(preset: .preset1280x720)!
        case .low: return AVOutputSettingsAssistant(preset: .preset640x480)!
        }
    }
    
    internal var videoSettings: [String: Any] {
        return self.settingsAssitant.videoSettings!
    }
    
    internal var audioSettings: [String: Any] {
        return self.settingsAssitant.audioSettings!
    }
    
}

public class MovieFileWriter {
    
    private var writer: AVAssetWriter
    private var videoInput: AVAssetWriterInput
    private var pixelAdaptor: AVAssetWriterInputPixelBufferAdaptor
    
    private var audioInput: AVAssetWriterInput?
    
    public var isWriting = false

    private var timescale: UInt32
    private var videoSamplesWritten: Int64 = 0
    
    private var currentPTS: CMTime {
        return CMTimeMake(videoSamplesWritten, Int32(self.timescale))
    }
    
    internal init(_ config: MovieFileConfig) throws {
        
        self.writer = try AVAssetWriter(outputURL: config.url, fileType: config.container.fileType)
        self.writer.directoryForTemporaryFiles = URL(fileURLWithPath: NSTemporaryDirectory())
        
        //////// Configure the video input
        let videoSettings = config.quality.videoSettings

        self.videoInput = AVAssetWriterInput(mediaType: .video,
                                             outputSettings: videoSettings,
                                             sourceFormatHint: config.videoFormat)
        
        self.videoInput.expectsMediaDataInRealTime           = true
        self.videoInput.performsMultiPassEncodingIfSupported = false
        
        print("====", CMTimeCodeFormatDescriptionGetFrameQuanta(config.videoFormat))
        self.timescale = CMTimeCodeFormatDescriptionGetFrameQuanta(config.videoFormat)
        
        
        let pixelAttrs    = [kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA)]
        self.pixelAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: self.videoInput,
                                                                 sourcePixelBufferAttributes: pixelAttrs)
        
        self.writer.add(self.videoInput)
        
        
        //////// Configure the audio input
        if let audioFmt = config.audioFormat {
            let audioSettings = config.quality.audioSettings
            
            let aInput = AVAssetWriterInput(mediaType: .audio,
                                            outputSettings: audioSettings,
                                            sourceFormatHint: audioFmt)
            
            aInput.expectsMediaDataInRealTime           = true
            aInput.performsMultiPassEncodingIfSupported = false
            self.audioInput                             = aInput
            self.writer.add(aInput)
        }
    }
    
    public func start() {
        self.start(at: kCMTimeZero)
    }
    
    public func start(at time: CMTime) {
        if self.writer.startWriting() {
            writer.startSession(atSourceTime: time)
            self.isWriting = true
        }
    }
    
    public func stop(_ onComplete: (() -> (Void))?) {
        self.stop(at: self.currentPTS, onComplete)
    }
    
    public func stop(at time: CMTime) {
        self.stop(at: time, nil)
    }
    
    public func stop(at time: CMTime, _ onComplete: (() -> (Void))?) {
        self.isWriting = false
        self.videoInput.markAsFinished()
        self.audioInput?.markAsFinished()
        self.writer.endSession(atSourceTime: time)
        
        self.writer.finishWriting {
            onComplete?()
        }
    }
    
    public func write(_ pixelBuffer: CVPixelBuffer, with pts: CMTime) {
        guard self.isWriting else { return }
        
        if self.writer.status != .unknown {
            if self.videoInput.isReadyForMoreMediaData {
                self.pixelAdaptor.append(pixelBuffer, withPresentationTime: pts)
            }
        }
    }
    
    public func write(_ sample: CMSampleBuffer, type: SampleType) {
        switch type {
        case .video:
            self.writeVideo(sample: sample)
        case .audio:
            self.writeAudio(sample: sample)
        }
    }
    
    private func writeVideo(sample: CMSampleBuffer) {
        guard self.isWriting else { return }
        
        if self.writer.status != .unknown {
            if self.videoInput.isReadyForMoreMediaData {
                print("output duration:", CMSampleBufferGetOutputDuration(sample))
                print("pts:", CMSampleBufferGetPresentationTimeStamp(sample))
                self.videoInput.append(sample)
                self.videoSamplesWritten += 1
            }
        }
    }
    
    private func writeAudio(sample: CMSampleBuffer) {
        guard let audioInput = self.audioInput else { return }
        guard self.isWriting else { return }
        
        if self.writer.status != .unknown {
            if audioInput.isReadyForMoreMediaData {
                audioInput.append(sample)
            }
        }
    }
    
}
