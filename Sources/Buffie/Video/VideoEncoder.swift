import Foundation
import VideoToolbox

public enum VideoEncoderError: Error {
    case initError
}

public protocol VideoEncoderDelegate {
    func encoded(videoSample: CMSampleBuffer)
}

public class VideoEncoder {
    
    public var settings: VideoEncoderSettings
    public var delegate: VideoEncoderDelegate
    
    fileprivate var session: VTCompressionSession?
    fileprivate var encodeCallback: VTCompressionOutputCallback = videoSampleCompressedCallback
        
    public init(_ settings: VideoEncoderSettings, delegate: VideoEncoderDelegate) throws {
        self.settings = settings
        self.delegate = delegate
        
        var status = noErr
        
        
        var encoderSpec: CFDictionary?
        #if os(macOS)
            encoderSpec = [kVTVideoEncoderSpecification_EnableHardwareAcceleratedVideoEncoder as String: self.settings.useHardwareEncoding] as CFDictionary
        #endif
        
        status = VTCompressionSessionCreate(kCFAllocatorDefault,
                                            settings.width,
                                            settings.height,
                                            settings.codec,
                                            encoderSpec,
                                            settings.imageBufferAttributes as CFDictionary?,
                                            nil,
                                            self.encodeCallback,
                                            unsafeBitCast(self, to: UnsafeMutableRawPointer.self),
                                            &self.session)
        
        if status == noErr {
            configureProperties(for: self.session!, with: settings)
        } else {
            throw VideoEncoderError.initError
        }
    }
    
    public func encode(_ sample: CMSampleBuffer) {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sample) {
            
            let pts         = CMSampleBufferGetPresentationTimeStamp(sample)
            let duration    = CMSampleBufferGetDuration(sample)
                        
            VTCompressionSessionEncodeFrame(self.session!,
                                            pixelBuffer,
                                            pts,
                                            duration,
                                            nil,
                                            nil,
                                            nil)
        }
    }
    
    internal func completeFrame() {
        VTCompressionSessionCompleteFrames(self.session!,
                                           CMTime(seconds: 1,
                                                  preferredTimescale: Int32(self.settings.frameRate)))
    }
    
}

func configureProperties(for session: VTCompressionSession,
                         with settings: VideoEncoderSettings)
{
    
    if let maxKeyFrameIntervalDuration = settings.maxKeyFrameIntervalDuration {
        VTSessionSetProperty(session,
                             kVTCompressionPropertyKey_MaxKeyFrameIntervalDuration,
                             maxKeyFrameIntervalDuration as CFTypeRef)
    }
    
    kVTCompressionPropertyKey_VideoEncoderPixelBufferAttributes
    kVTCompressionPropertyKey_PixelTransferProperties

    VTSessionSetProperty(session,
                         kVTCompressionPropertyKey_RealTime,
                         settings.realTime as CFBoolean)
    
    VTSessionSetProperty(session,
                         kVTCompressionPropertyKey_ExpectedFrameRate,
                         settings.frameRate as CFTypeRef)
    
    VTSessionSetProperty(session,
                         kVTCompressionPropertyKey_AllowFrameReordering,
                         settings.allowFrameReordering as CFBoolean)
    
    VTSessionSetProperty(session,
                         kVTCompressionPropertyKey_AllowTemporalCompression,
                         settings.allowTemporalCompression as CFBoolean)
    
    VTSessionSetProperty(session,
                         kVTCompressionPropertyKey_ProfileLevel,
                         settings.profileLevel.raw)
    
    if let bitRate = settings.bitRate {
        VTSessionSetProperty(session,
                             kVTCompressionPropertyKey_AverageBitRate,
                             bitRate as CFTypeRef)
    }
    
    if let dataRateLimit = settings.dataRateLimit {
        VTSessionSetProperty(session,
                             kVTCompressionPropertyKey_DataRateLimits,
                             dataRateLimit as CFTypeRef)
    }
    
}

let videoSampleCompressedCallback: VTCompressionOutputCallback = {outputRef, sourceFrameRef, status, infoFlags, sampleBuffer in
    let encoder: VideoEncoder = unsafeBitCast(outputRef, to: VideoEncoder.self)
    if status == noErr {
        if let sb = sampleBuffer {
            encoder.delegate.encoded(videoSample: sb)
        }
    }
}
