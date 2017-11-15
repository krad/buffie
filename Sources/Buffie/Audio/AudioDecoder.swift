import Foundation
import AVFoundation


@available (macOS 10.11, iOS 5, *)
public class AudioDecoder: AudioEncDecBase {
    
    public func decode(_ bytes: [UInt8]) {
        let ptr             = UnsafeMutablePointer(mutating: bytes)
        let bufferPtr       = UnsafeMutableBufferPointer(start: ptr, count: bytes.count)
        let audioBuffer     = AudioBuffer(bufferPtr, numberOfChannels: 2)
        var audioBufferList = AudioBufferList(mNumberBuffers: 1, mBuffers: audioBuffer)
        
        var error: NSError?
        memcpy(self.outBuffer.mutableAudioBufferList,
               &audioBufferList,
               MemoryLayout<AudioBufferList>.size)
        
        let status = self.converter.convert(to: self.inBuffer,
                                            error: &error,
                                            withInputFrom: self.workBlock!)
        
        if status != .endOfStream && status != .error {
            self.delegate.processed(self.inBuffer.audioBufferList.pointee, numberOfSamples: -1)
        }
                
    }
    
}
