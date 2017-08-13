import Foundation
import CoreMedia

let mediaStreamDelimeter: [UInt8] = [0x0, 0x0, 0x0, 0x1]

struct AVMuxerSettings {
    
    var videoSettings: VideoEncoderSettings
    var audioSettings: AudioEncoderSettings
    
    init() {
        self.videoSettings = VideoEncoderSettings()
        self.audioSettings = AudioEncoderSettings()
    }
    
}

public protocol AVMuxerDelegate {
    func muxed(data: [UInt8])
}

@available(OSX 10.11, iOS 5, *)
public class AVMuxer: CameraReader {

    fileprivate var delegate: AVMuxerDelegate?
    internal var videoEncoder: VideoEncoder?
    internal var audioEncoder: AudioEncoder?
    
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
        if let bytes = bytes(from: videoSample) {
            let packet: [UInt8] = mediaStreamDelimeter + [SampleType.video.rawValue] + bytes
            self.delegate?.muxed(data: packet)
        }
    }
}

@available(OSX 10.11, iOS 5, *)
extension AVMuxer: AudioEncoderDelegate {
    public func encoded(audioSample: AudioBufferList) {
        if let bytes = bytes(from: audioSample) {
            let packet: [UInt8] = mediaStreamDelimeter + [SampleType.audio.rawValue] + bytes
            self.delegate?.muxed(data: packet)
        }
    }
}

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
