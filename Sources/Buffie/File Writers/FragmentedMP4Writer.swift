import Foundation
import AVFoundation

class FragmentedMP4Writer {
    
    var videoEncoder: VideoEncoder?
    
    init() throws {
        let settings      = VideoEncoderSettings()
        self.videoEncoder = try VideoEncoder(settings, delegate: self)
    }
    
    func got(_ sample: CMSampleBuffer) {
        print(#function)
        self.videoEncoder?.encode(sample)
    }
    
}

extension FragmentedMP4Writer: VideoEncoderDelegate {
    
    func encoded(videoSample: CMSampleBuffer) {
        if let videoBytes = bytes(from: videoSample) {
            let naluSize = UInt32(bytes: Array(videoBytes[0..<4]))
            let naluType = videoBytes[4] & 0x1f
            print(naluSize, naluType)
            print(videoBytes)
        }
    }
    
}

public struct NALUStreamIterator: Sequence, IteratorProtocol {
    
    let streamBytes: [UInt8]
    var currentIdx: Int = 0
    
    mutating public func next() -> NALU? {
        
        guard self.currentIdx < streamBytes.count else { return nil }

        if let naluSize = UInt32(bytes: Array(streamBytes[currentIdx..<currentIdx+4])) {
            let nextIdx = currentIdx + Int(naluSize) + 4
            let nalu = NALU(data: Array(streamBytes[currentIdx..<nextIdx]))
            self.currentIdx += nextIdx
            return nalu
        }
        
        return nil
    }
    
}
