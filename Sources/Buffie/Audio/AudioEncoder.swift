import Foundation
import AVFoundation

public enum AudioEncoderError: Error {
    case couldNotInitialize
}

public protocol AudioEncoderDecoderDelegate {
    func processed(_ audioBuffer: AudioBufferList)
}

@available (macOS 10.11, iOS 5, *)
public class AudioEncoder: AudioEncDecBase {
    
    public func encode(_ sample: CMSampleBuffer) {
        var error: NSError?
        CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sample,
                                                                nil,
                                                                self.inBuffer.mutableAudioBufferList,
                                                                CMSampleBufferGetNumSamples(sample),
                                                                kCFAllocatorDefault,
                                                                kCFAllocatorDefault,
                                                                0,
                                                                nil)
        let status = self.converter.convert(to: self.outBuffer, error: &error, withInputFrom: self.workBlock!)
        if status != .endOfStream && status != .error {
            self.delegate.processed(self.outBuffer.audioBufferList.pointee)
        }
    }
    
}
