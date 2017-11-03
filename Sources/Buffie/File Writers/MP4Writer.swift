import Foundation
import AVFoundation

public class MP4Writer: MovieFileWriter {

    public init(_ fileURL: URL, videoFormat: CMFormatDescription, quality: MovieFileQuality = .high, videoBitrate: Int? = nil, audioFormat: CMFormatDescription? = nil) throws {
        
        let config = MovieFileConfig(url: fileURL,
                                     container: .mp4,
                                     quality: quality,
                                     videoBitRate: videoBitrate,
                                     videoFormat: videoFormat,
                                     audioFormat: audioFormat)
        
        try super.init(config)
    }
    
}
