import Foundation
import AVFoundation

public enum AudioEncoderError: Error {
    case couldNotInitialize
}

public protocol AudioEncoderDecoderDelegate {
    func processed(_ audioBufferList: AudioBufferList, numberOfSamples: Int)
}

@available (macOS 10.11, iOS 5, *)
public class AudioEncoder: AudioEncDecBase {
    
    var encoderQueue = DispatchQueue(label: "audioEncoder")
    
    public func encode(_ sample: CMSampleBuffer) {
        self.encoderQueue.async {
            
            var error: NSError?
            
            let numberOfSamples = CMSampleBufferGetNumSamples(sample)
            
            CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sample,
                                                                    nil,
                                                                    self.inBuffer.mutableAudioBufferList,
                                                                    numberOfSamples,
                                                                    kCFAllocatorDefault,
                                                                    kCFAllocatorDefault,
                                                                    0,
                                                                    nil)
            let status = self.converter.convert(to: self.outBuffer, error: &error, withInputFrom: self.workBlock!)
            if status != .endOfStream && status != .error {
                self.delegate.processed(self.outBuffer.audioBufferList.pointee,
                                        numberOfSamples: numberOfSamples)
            }
        }
    }
    
}
