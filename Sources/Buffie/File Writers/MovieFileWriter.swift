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
    case low      = "low"
    case medium   = "medium"
    case high     = "high"
    case veryhigh = "veryhight"
    case highest  = "highest"
    
    internal var settingsAssitant: AVOutputSettingsAssistant {
        switch self {
        case .highest: return AVOutputSettingsAssistant(preset: .preset3840x2160)!
        case .veryhigh: return AVOutputSettingsAssistant(preset: .preset1920x1080)!
        case .high: return AVOutputSettingsAssistant(preset: .preset1280x720)!
        case .medium: return AVOutputSettingsAssistant(preset: .preset960x540)!
        case .low: return AVOutputSettingsAssistant(preset: .preset640x480)!
        }
    }
    
    internal func videoSettings(sourceFormat: CMFormatDescription) -> [String: Any] {
        let assistant               = self.settingsAssitant
        assistant.sourceVideoFormat = sourceFormat
        return assistant.videoSettings!
    }
    
    internal func audioSettings(sourceFormat: CMFormatDescription?) -> [String: Any] {
        let assistant               = self.settingsAssitant
        assistant.sourceAudioFormat = sourceFormat
        return assistant.audioSettings!
    }
    
}

public class MovieFileWriter {
    
    private var writer: AVAssetWriter
    private var videoInput: AVAssetWriterInput
    private var pixelAdaptor: AVAssetWriterInputPixelBufferAdaptor
    
    private var audioInput: AVAssetWriterInput?
    
    public var isWriting = false

    private var timescale: CMTimeScale
    private var lastDuration: Int64 = 0
    
    private var currentPTS: CMTime {
        return CMTimeMake(lastDuration, self.timescale)
    }
    
    internal init(_ config: MovieFileConfig) throws {
        
        self.writer = try AVAssetWriter(outputURL: config.url, fileType: config.container.fileType)
        self.writer.directoryForTemporaryFiles = URL(fileURLWithPath: NSTemporaryDirectory())
        
        //////// Configure the video input
        var videoSettings = config.quality.videoSettings(sourceFormat: config.videoFormat)

        self.timescale = 30_000
        if var compressionSettings = videoSettings[AVVideoCompressionPropertiesKey] as? [String: Any]{
            if let fps = compressionSettings[AVVideoExpectedSourceFrameRateKey] as? NSNumber {
                self.timescale = fps.int32Value * 1000
                print("==== CHANGED", fps, fps.intValue * 1000)
                print(CMTimeCodeFormatDescriptionGetFrameQuanta(config.videoFormat))
                print(CMTimeCodeFormatDescriptionGetFrameDuration(config.videoFormat))
            }
            
            if let bitrate = config.videoBitRate {
                compressionSettings[AVVideoAverageBitRateKey] = NSNumber(value: bitrate)
                videoSettings[AVVideoCompressionPropertiesKey] = compressionSettings
            }            
        }
        
        self.videoInput = AVAssetWriterInput(mediaType: .video,
                                             outputSettings: videoSettings,
                                             sourceFormatHint: config.videoFormat)
        
        self.videoInput.expectsMediaDataInRealTime           = true
        self.videoInput.performsMultiPassEncodingIfSupported = false
        self.videoInput.mediaTimeScale                       = self.timescale
        
        
        let pixelAttrs    = [kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA)]
        self.pixelAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: self.videoInput,
                                                                 sourcePixelBufferAttributes: pixelAttrs)
        
        self.writer.add(self.videoInput)
        
        
        //////// Configure the audio input
        if let audioFmt = config.audioFormat {
            let audioSettings = config.quality.audioSettings(sourceFormat: audioFmt)
            
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
        guard self.isWriting else { return }
        
        self.isWriting = false
        self.videoInput.markAsFinished()
        self.audioInput?.markAsFinished()
        self.writer.endSession(atSourceTime: time)
        
        self.writer.finishWriting {
            onComplete?()
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
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sample) {
            print(CMSampleBufferGetPresentationTimeStamp(sample))
            print(CMSampleBufferGetOutputDuration(sample))
            self.write(pixelBuffer, with: self.currentPTS)
            self.lastDuration += CMSampleBufferGetOutputDuration(sample).value
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
    
    internal func write(_ pixelBuffer: CVPixelBuffer, with pts: CMTime) {
        guard self.isWriting else { return }
        
        if self.writer.status != .unknown {
            if self.videoInput.isReadyForMoreMediaData {
                self.pixelAdaptor.append(pixelBuffer, withPresentationTime: pts)
            }
        }
    }

    
}
