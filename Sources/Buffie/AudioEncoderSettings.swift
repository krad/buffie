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
    var sampleRate: Float
    var channels: Int
    var interleaved: Bool
    
    init() {
        self.codec       = kCMAudioCodecType_AAC_LCProtected
        self.sampleRate  = 44100.0
        self.channels    = 2
        self.interleaved = true
    }
    
}
