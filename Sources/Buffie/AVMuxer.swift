//
//  AVMuxer.swift
//  BuffieTests
//
//  Created by Mel Gray on 8/6/17.
//

import Foundation
import CoreMedia

let mediaStreamDelimeter = [0x0, 0x0, 0x0, 0x1]

struct AVMuxerSettings {
    
    var videoSettings: VideoEncoderSettings
    var audioSettings: AudioEncoderSettings
    
    init() {
        self.videoSettings = VideoEncoderSettings()
        self.audioSettings = AudioEncoderSettings()
    }
    
}

@available(OSX 10.11, iOS 5, *)
public class AVMuxer: CameraReader {
    
    var videoEncoder: VideoEncoder?
    var audioEncoder: AudioEncoder?
    
    override init() {
        super.init()
    }
    
    convenience init(settings: AVMuxerSettings) throws {
        self.init()
        self.videoEncoder = try VideoEncoder(settings.videoSettings, delegate: self)
        self.audioEncoder = try AudioEncoder(settings.audioSettings, delegate: self)
    }

    public override func got(_ sample: CMSampleBuffer, type: SampleType) {
        print(#function)
    }
    
}

@available(OSX 10.11, iOS 5, *)
extension AVMuxer: VideoEncoderDelegate {
    public func encoded(videoSample: CMSampleBuffer) {
        
    }
}

@available(OSX 10.11, iOS 5, *)
extension AVMuxer: AudioEncoderDelegate {
    public func encoded(audioSample: AudioBufferList) {
        
    }
}
