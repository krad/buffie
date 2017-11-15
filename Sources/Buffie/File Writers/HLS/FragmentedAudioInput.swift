import CoreMedia

@available (macOS 10.11, *)
class FragmentedAudioInput {
    
    var settings = AudioEncoderDecoderSettings(.encoding)
    var audioEncoder: AudioEncoder?
    var onChunk: (AudioSample) -> Void
    var frames: Int = 0
    
    init(_ onChunk: @escaping (AudioSample) -> Void) throws {
        self.onChunk = onChunk
        self.settings.outSettings.audioFormat = kAudioFormatMPEG4AAC_ELD_V2
        self.audioEncoder = try AudioEncoder(self.settings, delegate: self)
    }
    
    func append(_ sample: CMSampleBuffer) {
        self.audioEncoder?.encode(sample)
    }
    
}

@available (macOS 10.11, *)
extension FragmentedAudioInput: AudioEncoderDecoderDelegate {
    func processed(_ audioBufferList: AudioBufferList) {
        self.onChunk(AudioSample(audioBufferList: audioBufferList, settings: self.settings.outSettings))
    }
}
