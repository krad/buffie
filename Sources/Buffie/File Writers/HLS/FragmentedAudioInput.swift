import CoreMedia

class FragmentedAudioInput {
    
    var onChunk: (AudioSample) -> Void
    var frames: Int = 0
    
    var decodeCount: Int64 = 0
    
    init(_ onChunk: @escaping (AudioSample) -> Void) throws {
        self.onChunk = onChunk
    }
    
    func append(_ sample: CMSampleBuffer) {
        
        let duration    = CMSampleBufferGetDuration(sample)
        decodeCount     += duration.value
        
        var audioSample      = AudioSample(sampleBuffer: sample)
        audioSample.duration = Double(duration.value)
        audioSample.decode   = Double(decodeCount)
        
        self.onChunk(audioSample)
    }
    
}
