import Foundation
import AVFoundation

public protocol AudioEncoderDelegateProtocol {
    func encoded(_ sample: CMSampleBuffer)
}

public class AudioEncoder {
    
    private var settings: AudioEncoderSettings
    private var delegate: AudioEncoderDelegateProtocol
    
    private let engine: AVAudioEngine
    private let inputNode: AVAudioNode
    
    init(_ settings: AudioEncoderSettings, delegate: AudioEncoderDelegateProtocol) throws {
        self.settings = settings
        self.delegate = delegate
        
        self.engine    = AVAudioEngine()
        self.inputNode = AVAudioNode()
    }
    
    public func encode(_ sample: CMSampleBuffer) {
        
    }
    
}
