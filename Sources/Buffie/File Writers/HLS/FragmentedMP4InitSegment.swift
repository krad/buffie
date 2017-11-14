import Foundation
import CoreMedia

class FragementedMP4InitalizationSegment {
    
    init(_ file: URL, videoFormat: CMFormatDescription, sample: Sample) throws {
        
        var config            = MOOVConfig()
        var videoConfig       = MOOVVideoSettings(videoFormat)
        videoConfig.timescale = UInt32(sample.duration.timescale)
        config.videoSettings  = videoConfig
        
        let ftypBytes = try BinaryEncoder.encode(FTYP())
        let moovBytes = try BinaryEncoder.encode(MOOV(config))
        
        let data = Data(bytes: ftypBytes + moovBytes)
        try data.write(to: file)
    }
}
