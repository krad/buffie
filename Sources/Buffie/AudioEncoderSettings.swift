//
//  AudioEncoderSettings.swift
//  BuffieTests
//
//  Created by Mel Gray on 7/31/17.
//

import Foundation
import CoreMedia

public struct AudioEncoderSettings {
    
    var codec: CMAudioCodecType
    var sampleRate: Double
    var channels: UInt32
    var interleaved: Bool
    
    init() {
        self.codec       = kCMAudioCodecType_AAC_LCProtected
        self.sampleRate  = 44100.0
        self.channels    = 2
        self.interleaved = true
    }
    
    var formatDescription: AudioStreamBasicDescription {
        return AudioStreamBasicDescription(mSampleRate: self.sampleRate,
                                           mFormatID: kAudioFormatMPEG4AAC,
                                           mFormatFlags: 0,
                                           mBytesPerPacket: 0,
                                           mFramesPerPacket: 0,
                                           mBytesPerFrame: 0,
                                           mChannelsPerFrame: self.channels,
                                           mBitsPerChannel: 0,
                                           mReserved: 0)
    }
    
}
