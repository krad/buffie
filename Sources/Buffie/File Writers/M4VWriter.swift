import Foundation
import AVFoundation

public class M4VWriter: MovieFileWriter {
    
    public init(_ fileURL: URL, videoFormat: CMFormatDescription, quality: MovieFileQuality = .high, videoBitrate: Int? = nil, audioFormat: CMFormatDescription? = nil) throws {

        let config = MovieFileConfig(url: fileURL,
                                     container: .m4v,
                                     quality: .high,
                                     videoBitRate: videoBitrate,
                                     videoFormat: videoFormat,
                                     audioFormat: audioFormat)
        
        try super.init(config)
    }

}
