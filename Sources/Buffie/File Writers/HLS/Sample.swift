import Foundation
import CoreMedia

protocol Sample {
    var type: SampleType { get }
    var data: [UInt8] { get }
}

public struct VideoSample: Sample {
    
    var type: SampleType
    var format: CMFormatDescription
    var nalus: [NALU] = []
    
    var data: [UInt8] {
        var results: [UInt8] = []
        for nalu in nalus {
            results.append(contentsOf: nalu.data)
        }
        return results
    }
    
    var duration: CMTime
    var pts: CMTime
    var decode: CMTime
    
    var size: UInt32 {
        return self.nalus.reduce(0, { last, nalu in last + nalu.totalSize })
    }
    
    var dependsOnOthers: Bool = false
    var isSync: Bool = false
    var earlierDisplayTimesAllowed: Bool = false
    
    init(sampleBuffer: CMSampleBuffer) {
        self.type       = .video
        self.format     = CMSampleBufferGetFormatDescription(sampleBuffer)!
        self.duration   = CMSampleBufferGetDuration(sampleBuffer)
        self.pts        = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        self.decode     = CMSampleBufferGetDecodeTimeStamp(sampleBuffer)
        
        self.isSync                     = !sampleBuffer.notSync
        self.dependsOnOthers            = sampleBuffer.dependsOnOthers
        self.earlierDisplayTimesAllowed = sampleBuffer.earlierPTS
        
        if let bytes = bytes(from: sampleBuffer) {
            for nalu in NALUStreamIterator(streamBytes: bytes, currentIdx: 0) {
                self.nalus.append(nalu)
            }
        }
    }
    
}

public struct AudioSample: Sample {
    
    var type: SampleType
    var data: [UInt8]
    
    var channels: UInt32
    var sampleRate: UInt32
    var bitDepth: UInt16
    var format: AudioFormatID
    
    init(audioBufferList: AudioBufferList, settings: AudioCodingSettings) {
        self.type = .audio
        if let bufferData = bytes(from: audioBufferList) {
            self.data = bufferData
        } else {
            self.data = []
        }
        
        self.channels   = settings.channels
        self.sampleRate = UInt32(settings.sampleRate)
        self.bitDepth   = settings.bitDepth
        self.format     = settings.audioFormat
    }
    
}
