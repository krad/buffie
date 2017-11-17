import Foundation
import CoreMedia

protocol Sample {
    var type: SampleType { get }
    var data: [UInt8] { get }
    var size: UInt32 { get }
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
    
    var size: UInt32 {
        return UInt32(self.data.count)
    }
    
    var channels: UInt32
    var sampleRate: Double

    var duration: CMTime
    var pts: CMTime
    var decode: CMTime
    
    var asbd: AudioStreamBasicDescription
    var sampleSize: UInt16
    
    init(sampleBuffer: CMSampleBuffer) {
        
        self.type       = .audio
        self.data       = bytes(from: sampleBuffer)!
        self.asbd       = getStreamDescription(from: sampleBuffer)!
        self.channels   = asbd.mChannelsPerFrame
        self.sampleRate = asbd.mSampleRate
        self.duration   = CMSampleBufferGetDuration(sampleBuffer)
        self.pts        = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        self.decode     = CMSampleBufferGetDecodeTimeStamp(sampleBuffer)
        
        var packet = AudioStreamPacketDescription()
        var packetSize: Int = 0
        CMSampleBufferGetAudioStreamPacketDescriptions(sampleBuffer, Int(asbd.mFramesPerPacket), &packet, &packetSize)
        
        self.sampleSize = UInt16(packetSize)
//        print(packet, packetSize)
    }
    

}
