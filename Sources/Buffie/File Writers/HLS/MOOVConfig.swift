import CoreMedia

struct MOOVConfig {
    
    var videoSettings: MOOVVideoSettings?
    var audioSettings: MOOVAudioSettings?
    
    init() { }
    
}

struct MOOVVideoSettings {
    
    var sps: [UInt8]
    var pps: [UInt8]
    var width: UInt32
    var height: UInt32
    var timescale: UInt32 = 30000
    
    init(_ format: CMFormatDescription) {
        let paramSet = getVideoFormatDescriptionData(format)
        self.sps = paramSet.first!
        self.pps = paramSet.last!
        
        let dimensions = CMVideoFormatDescriptionGetDimensions(format)
        self.width     = UInt32(dimensions.width)
        self.height    = UInt32(dimensions.height)
    }
    
}

struct MOOVAudioSettings {
    
    var channels: UInt32   = 2
    var sampleSize: UInt32 = 16
    var sampleRate: UInt32 = 44100
    var bitDepth: UInt16   = 8
    var format: AudioFormatID
    
    init(_ sample: AudioSample) {
        self.channels   = sample.channels
        self.sampleSize = UInt32(sample.data.count)
        self.sampleRate = sample.sampleRate
        self.bitDepth   = sample.bitDepth
        self.format     = sample.format
    }
    
}



