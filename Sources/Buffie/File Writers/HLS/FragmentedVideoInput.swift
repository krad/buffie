import CoreMedia

class FragmentedVideoInput {
    
    var settings = VideoEncoderSettings()
    var videoEncoder: VideoEncoder?
    var onChunk: (VideoSample) -> Void
    
    init(_ onChunk: @escaping (VideoSample) -> Void) throws {
        self.onChunk = onChunk
        self.settings.allowFrameReordering        = false
        self.settings.profileLevel                = .h264High_4_0
        self.settings.maxKeyFrameIntervalDuration = 2
        self.videoEncoder = try VideoEncoder(settings, delegate: self)
    }
    
    func append(_ sample: CMSampleBuffer) {
        self.videoEncoder?.encode(sample)
    }
    
}

extension FragmentedVideoInput: VideoEncoderDelegate {
    func encoded(videoSample: CMSampleBuffer) {
        self.onChunk(VideoSample(sampleBuffer: videoSample))
    }
}
