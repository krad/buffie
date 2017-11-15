import Foundation
import AVFoundation

public enum AudioEncoderError: Error {
    case couldNotInitialize
}

public protocol AudioEncoderDecoderDelegate {
    func processed(_ audioBufferList: AudioBufferList)
}

@available (macOS 10.11, iOS 5, *)
public class AudioEncoder: AudioEncDecBase {
    
    var encoderQueue = DispatchQueue(label: "audioEncoder")
    
    public func encode(_ sample: CMSampleBuffer) {
        self.encoderQueue.async {
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
    
}
