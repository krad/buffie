import Foundation
import VideoToolbox

public struct VideoEncoderSettings {
    
    public var width: Int32
    public var height: Int32
    public var codec: CMVideoCodecType
    public var videoFormat: VideoFormat
    public var frameRate: Int
    public var maxKeyFrameIntervalDuration: Int?
    
    public var realTime: Bool
    public var dataRateLimit: Int?
    public var bitRate: Int?
    public var allowFrameReordering: Bool
    public var allowTemporalCompression: Bool
    public var profileLevel: VideoProfileLevel
    public var useHardwareEncoding: Bool
    
    public init() {
        self.width                    = 640
        self.height                   = 480
        self.codec                    = kCMVideoCodecType_H264
        self.frameRate                = 30
        self.videoFormat              = .x420YpCbCr8BiPlanarVideoRange
        self.realTime                 = true
        self.allowFrameReordering     = true
        self.allowTemporalCompression = true
        self.profileLevel             = .h264Baseline_3_0
        self.useHardwareEncoding      = true
    }
    
    var imageBufferAttributes: [NSString: AnyObject] {
        return [kCVPixelBufferPixelFormatTypeKey: self.videoFormat.raw as AnyObject,
                kCVPixelBufferWidthKey: NSNumber(value: self.width),
                kCVPixelBufferHeightKey: NSNumber(value: self.height)]
    }
    
}

public enum VideoFormat {
    case x420YpCbCr8BiPlanarVideoRange
    case x32ARGB
    
    var raw: UInt32 {
        get {
            switch self {
            case .x420YpCbCr8BiPlanarVideoRange:
                return kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
            case .x32ARGB:
                return kCVPixelFormatType_32ARGB
                
            }
        }
    }
    
}

// Only supporting profiles supported by HLS.
//https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/StreamingMediaGuide/FrequentlyAskedQuestions/FrequentlyAskedQuestions.html
public enum VideoProfileLevel {
    
    case h264Baseline_3_0
    case h264Baseline_3_1
    case h264Main_3_1
    case h264High_4_1
    
    var raw: CFString {
        get {
            switch self {
            case .h264Baseline_3_0:
                return kVTProfileLevel_H264_Baseline_3_0
            case .h264Baseline_3_1:
                return kVTProfileLevel_H264_Baseline_3_1
            case .h264Main_3_1:
                return kVTProfileLevel_H264_Main_3_1
            case .h264High_4_1:
                return kVTProfileLevel_H264_High_4_1
            }
        }
    }
}
