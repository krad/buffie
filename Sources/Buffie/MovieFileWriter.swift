import Foundation
import AVFoundation

public class MovieFileWriter {
    
    private var writer: AVAssetWriter
    private var videoInput: AVAssetWriterInput
    private var pixelAdaptor: AVAssetWriterInputPixelBufferAdaptor
    
    private var audioInput: AVAssetWriterInput?
    
    private var videoFramesWrote: Int64 = 0
    
    private var isWriting = false
    
    internal init(fileType: AVFileType, fileURL: URL, videoFormat: CMFormatDescription, audioFormat: CMFormatDescription? = nil) throws {
        
        self.writer = try AVAssetWriter(outputURL: fileURL, fileType: fileType)
        self.writer.directoryForTemporaryFiles = URL(fileURLWithPath: NSTemporaryDirectory())
        
        //////// Configure the video input
        let dimensions = CMVideoFormatDescriptionGetDimensions(videoFormat)
        
        let videoSettings: [String: Any] = [AVVideoCodecKey: AVVideoCodecH264,
                                            AVVideoWidthKey: NSNumber(value: dimensions.width),
                                            AVVideoHeightKey: NSNumber(value: dimensions.height),
                                            AVVideoCompressionPropertiesKey: [AVVideoMaxKeyFrameIntervalKey: NSNumber(value: 24),
                                                                              AVVideoProfileLevelKey: AVVideoProfileLevelH264BaselineAutoLevel,
                                                                              AVVideoAverageBitRateKey: NSNumber(value: 25000)]
        ]
        
        self.videoInput = AVAssetWriterInput(mediaType: .video,
                                             outputSettings: videoSettings,
                                             sourceFormatHint: videoFormat)
        
        self.videoInput.expectsMediaDataInRealTime           = true
        self.videoInput.performsMultiPassEncodingIfSupported = true
        self.videoInput.mediaTimeScale                       = 600 * 100000
        
        
        let pixelAttrs    = [kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA)]
        self.pixelAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: self.videoInput,
                                                                 sourcePixelBufferAttributes: pixelAttrs)
        
        self.writer.add(self.videoInput)
        
        
        //////// Configure the audio input
        if let audioFmt = audioFormat {
            if let asbd = CMAudioFormatDescriptionGetStreamBasicDescription(audioFmt)?.pointee {
                var channelLayout = AudioChannelLayout()
                memset(&channelLayout, 0, MemoryLayout<AudioChannelLayout>.size);
                channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo
                
                let audioSettings: [String: Any] = [AVFormatIDKey: kAudioFormatMPEG4AAC,
                                                    AVSampleRateKey: asbd.mSampleRate,
                                                    AVNumberOfChannelsKey: 2,
                                                    AVChannelLayoutKey: NSData(bytes:&channelLayout, length:MemoryLayout<AudioChannelLayout>.size)]
                
                let aInput = AVAssetWriterInput(mediaType: .audio,
                                                outputSettings: audioSettings,
                                                sourceFormatHint: audioFormat)
                
                aInput.expectsMediaDataInRealTime           = true
                aInput.performsMultiPassEncodingIfSupported = false
                self.audioInput                             = aInput
                self.writer.add(aInput)
            }
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
                self.videoFramesWrote += 1
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
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sample) {
            
            let fpsOutput: Int64 = 24; //Some possible values: 30, 10, 15 24, 25, 30/1.001 or 29.97;
            let cmTimeSecondsDenominatorTimescale: Int32 = 600 * 100000; //To more precisely handle 29.97.
            let cmTimeNumeratorValue: Int64 = Int64(cmTimeSecondsDenominatorTimescale) / fpsOutput;
            let pts = CMTimeMake( videoFramesWrote * cmTimeNumeratorValue, cmTimeSecondsDenominatorTimescale);
            
            self.write(pixelBuffer, with: pts)
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
