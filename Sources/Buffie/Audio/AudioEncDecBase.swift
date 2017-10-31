import Foundation
import AVFoundation

@available (macOS 10.11, iOS 5, *)
public class AudioEncDecBase {
    
    internal var settings: AudioEncoderDecoderSettings
    internal var delegate: AudioEncoderDecoderDelegate
    
    internal var inputFormat: AVAudioFormat
    internal var outputFormat: AVAudioFormat
    internal var converter: AVAudioConverter
    internal var inBuffer: AVAudioPCMBuffer
    internal var outBuffer: AVAudioCompressedBuffer
    internal var workBlock: AVAudioConverterInputBlock?
    
    internal var direction: AudioConverterFlow
    
    init(_ settings: AudioEncoderDecoderSettings, delegate: AudioEncoderDecoderDelegate) throws {
        
        // Wire up settings / format descriptions
        self.settings = settings
        self.delegate = delegate
        
        // Create the formats usable by the audio converter
        guard let inFormat  = settings.inSettings.format,
              let outFormat = settings.outSettings.format
        else { throw AudioEncoderError.couldNotInitialize }
        
        self.inputFormat  = inFormat
        self.outputFormat = outFormat
        
        if let converter = AVAudioConverter(from: self.inputFormat,
                                            to: self.outputFormat) { self.converter = converter }
        else { throw AudioEncoderError.couldNotInitialize }
        
    
        var iFormat    = self.inputFormat
        var oFormat    = self.outputFormat
        self.direction = .encoding
        
        if self.inputFormat.streamDescription.pointee.mFormatID != kAudioFormatLinearPCM {
            iFormat        = self.outputFormat
            oFormat        = self.inputFormat
            self.direction = .decoding
        }
        
        self.inBuffer             = AVAudioPCMBuffer(pcmFormat: iFormat, frameCapacity: 1024)!
        self.inBuffer.frameLength = self.inBuffer.frameCapacity
        
        self.outBuffer            = AVAudioCompressedBuffer(format: oFormat,
                                                            packetCapacity: 32,
                                                            maximumPacketSize: self.converter.maximumOutputPacketSize)
        
        self.workBlock = { inNumPackets, outStatus in
            outStatus.pointee = AVAudioConverterInputStatus.haveData
            if self.direction == .encoding {
                return self.inBuffer
            } else {
                return self.outBuffer
            }
        }
    }
}
