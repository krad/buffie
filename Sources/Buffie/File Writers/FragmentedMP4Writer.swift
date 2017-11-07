import Foundation
import AVFoundation

class FragmentedMP4Writer {
    
    var videoEncoder: VideoEncoder?
    
    init() throws {
        let settings      = VideoEncoderSettings()
        self.videoEncoder = try VideoEncoder(settings, delegate: self)
    }
    
    func got(_ sample: CMSampleBuffer) {
        self.videoEncoder?.encode(sample)
    }
    
}

extension FragmentedMP4Writer: VideoEncoderDelegate {
    
    func encoded(videoSample: CMSampleBuffer) {
        if let videoBytes = bytes(from: videoSample) {
            let iterator = NALUStreamIterator(streamBytes: videoBytes, currentIdx: 0)
            for nalu in iterator {
                print(nalu)
            }
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
