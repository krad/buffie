import CoreMedia

class FragmentedAudioInput {
    
    var onChunk: (AudioSample) -> Void
    var frames: Int = 0
    
    init(_ onChunk: @escaping (AudioSample) -> Void) throws {
        self.onChunk = onChunk
    }
    
    func append(_ sample: CMSampleBuffer) {
        self.onChunk(AudioSample(sampleBuffer: sample))
    }
    
}
