import Foundation
import CoreMedia
import AVKit

enum AudioConverterFlow {
    case encoding
    case decoding
}


/// Wrapper to configure input and output settings for an Audio Encoder/Decoder
public struct AudioEncoderDecoderSettings {
    
    var inSettings: AudioCodingSettings
    var outSettings: AudioCodingSettings
    
    init(_ flow: AudioConverterFlow) {
        switch flow {
        case .encoding:
            self.inSettings             = AudioCodingSettings()
            self.inSettings.audioFormat = kAudioFormatLinearPCM
            self.outSettings            = AudioCodingSettings()
            self.outSettings.audioFormat = kAudioFormatMPEG4AAC_ELD_SBR
            
        case .decoding:
            self.inSettings              = AudioCodingSettings()
            self.inSettings.audioFormat  = kAudioFormatMPEG4AAC_ELD_SBR
            
            self.outSettings             = AudioCodingSettings()
            self.outSettings.audioFormat = kAudioFormatLinearPCM
        }
    }
    
}


/// Convienence wrapper for putting together an audio stream description
public struct AudioCodingSettings {
    
    var sampleRate: Double
    var audioFormat: AudioFormatID
    var channels: UInt32
    var interleaved: Bool
    
    init() {
        self.sampleRate  = 44100.0
        self.audioFormat = kAudioFormatMPEG4AAC_ELD_SBR
        self.channels    = 2
        self.interleaved = false
    }

    var format: AVAudioFormat? {
        
        let settings: [String: Any] = [
            AVFormatIDKey: self.audioFormat,
            AVSampleRateKey: self.sampleRate,
            AVNumberOfChannelsKey: self.channels,
            AVLinearPCMBitDepthKey: 8,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false,
        ]
        
        return AVAudioFormat(settings: settings)
        
    }
    
}