import CoreMedia

@available (macOS 10.11, *)
class FragmentedAudioInput {
    
    //var settings = AudioEncoderDecoderSettings(.encoding)
    var onChunk: (AudioSample) -> Void
    var frames: Int = 0
    
    init(_ onChunk: @escaping (AudioSample) -> Void) throws {
        self.onChunk = onChunk
//        self.audioEncoder = try AudioEncoder(self.settings, delegate: self)
    }
    
    func append(_ sample: CMSampleBuffer) {
//        self.audioEncoder?.encode(sample)
    }
    
}
