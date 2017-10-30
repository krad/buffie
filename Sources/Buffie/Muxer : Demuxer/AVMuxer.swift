import Foundation
import CoreMedia

let mediaStreamDelimeter: [UInt8] = [0x0, 0x0, 0x0, 0x1]
let paramSetMarker: UInt8         = 0x70

struct AVMuxerSettings {
    
    var videoSettings: VideoEncoderSettings
    var audioSettings: AudioEncoderSettings
    
    init() {
        self.videoSettings = VideoEncoderSettings()
        self.audioSettings = AudioEncoderSettings()
    }
    
}

public protocol AVMuxerDelegate {
    func got(paramSet: [[UInt8]])
    func muxed(data: [UInt8])
}

@available(OSX 10.11, iOS 5, *)
public class AVMuxer: CameraReader {

    fileprivate var delegate: AVMuxerDelegate?
    internal var videoEncoder: VideoEncoder?
    internal var audioEncoder: AudioEncoder?
    internal var parameterSetData: [[UInt8]]? {
        didSet {
            if let params = parameterSetData {
                self.delegate?.got(paramSet: params)
            }
        }
    }
    
    override init() {
        super.init()
    }
    
    convenience init(settings: AVMuxerSettings = AVMuxerSettings(), delegate: AVMuxerDelegate) throws {
        self.init()
        self.delegate     = delegate
        self.videoEncoder = try VideoEncoder(settings.videoSettings, delegate: self)
        self.audioEncoder = try AudioEncoder(settings.audioSettings, delegate: self)
    }

    public override func got(_ sample: CMSampleBuffer, type: SampleType) {
        switch type {
        case .video: self.videoEncoder?.encode(sample)
        case .audio: self.audioEncoder?.encode(sample)
        }
    }
    
}

@available(OSX 10.11, iOS 5, *)
extension AVMuxer: VideoEncoderDelegate {
    public func encoded(videoSample: CMSampleBuffer) {
        
        if self.parameterSetData == nil {
            self.parameterSetData = getFormatDescriptionData(videoSample)
        }
        
        if let bytes = bytes(from: videoSample) {
            let packet: [UInt8] =  [SampleType.video.rawValue] + bytes
            self.delegate?.muxed(data: packet)
        }
    }
}

@available(OSX 10.11, iOS 5, *)
extension AVMuxer: AudioEncoderDelegate {
    public func encoded(audioSample: AudioBufferList) {
        if let bytes = bytes(from: audioSample) {
            let packet: [UInt8] =  [SampleType.audio.rawValue] + bytes
            self.delegate?.muxed(data: packet)
        }
    }
}


/// Converts a CMSampleBuffer to an array of unsigned 8 bit integers
///
/// - Parameter sample: CMSampleBuffer
/// - Returns: Array of unsigned 8 bit integers
internal func bytes(from sample: CMSampleBuffer) -> [UInt8]? {
    if let dataBuffer = CMSampleBufferGetDataBuffer(sample) {
        var bufferLength: Int = 0
        var bufferDataPointer: UnsafeMutablePointer<Int8>? = nil
        CMBlockBufferGetDataPointer(dataBuffer, 0, nil, &bufferLength, &bufferDataPointer)
        
        var nalu = [UInt8](repeating: 0, count: bufferLength)
        CMBlockBufferCopyDataBytes(dataBuffer, 0, bufferLength, &nalu)
        return nalu
    }
    
    return nil
}


/// Converts an AudioBufferList to an array of unsigned 8 bit integers
///
/// - Parameter audioBufferList: AudioBufferList with buffers of audio
/// - Returns: Array of unsigned 8 bit integers
internal func bytes(from audioBufferList: AudioBufferList) -> [UInt8]? {
    var result: [UInt8] = []
    
    var shallowBuffer = audioBufferList
    let buffers = UnsafeBufferPointer<AudioBuffer>(start: &shallowBuffer.mBuffers, count: Int(audioBufferList.mNumberBuffers))
    for buffer in buffers {
        if let framePtr = buffer.mData?.assumingMemoryBound(to: UInt8.self) {
            let frameArray = Array(UnsafeBufferPointer(start: framePtr, count: Int(buffer.mDataByteSize)))
            result         = result + frameArray
        }
    }
    
    if result.count > 0 {
        return result
    }
    
    return nil
}


/// Get's the SPS & PPS data from an h264 sample
///
/// - Parameter buffer: CMSampleBuffer of h264 data
/// - Returns: Data representing SPS and PPS bytes
internal func getFormatDescriptionData(_ buffer: CMSampleBuffer) -> [[UInt8]] {
    var results: [[UInt8]] = []
    
    if let description = CMSampleBufferGetFormatDescription(buffer) {
        var numberOfParamSets: size_t = 0
        CMVideoFormatDescriptionGetH264ParameterSetAtIndex(description, 0, nil, nil, &numberOfParamSets, nil)
        
        for idx in 0..<numberOfParamSets {
            var params: UnsafePointer<UInt8>? = nil
            var paramsLength: size_t         = 0
            var headerLength: Int32          = 4
            CMVideoFormatDescriptionGetH264ParameterSetAtIndex(description, idx, &params, &paramsLength, nil, &headerLength)
            
//            let length      = UInt32(paramsLength)
//            let lengthBytes = byteArray(from: length)            
            let bufferPointer   = UnsafeBufferPointer(start: params, count: paramsLength)
            let paramsUnwrapped = Array(bufferPointer)
            
            let result: [UInt8] =  paramsUnwrapped
            results.append(result)
        }
    }
    
    return results
}
