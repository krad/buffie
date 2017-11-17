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
    var sampleRate: UInt32
    var bitDepth: UInt16
    var format: AudioFormatID
    
    static func samples(from audioBufferList: AudioBufferList,
                        numberOfSamples: Int) -> [AudioSample] {
        
        var results: [AudioSample] = []

//        if let bufferData = bytes(from: audioBufferList) {
//                        
//            let sampleLength = (bufferData.count / numberOfSamples) * 128
//            let samplesArray: [[UInt8]] =
//            stride(from: 0, through: bufferData.count, by: sampleLength).map { startIndex in
//                let endIndex = min(bufferData.count, startIndex.advanced(by: sampleLength))
//                return Array(bufferData[startIndex..<endIndex])
//            }
//
//            results = samplesArray.map {
//                AudioSample(type: .audio,
//                            data: $0,
//                            channels: settings.channels,
//                            sampleRate: UInt32(settings.sampleRate),
//                            bitDepth: settings.bitDepth,
//                            format: settings.audioFormat)
//            }
//            
//        }
//
        
        return results
    }

}
