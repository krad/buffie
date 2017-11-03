import Foundation
import AVFoundation

public class MOVWriter: MovieFileWriter {
    
    public init(_ fileURL: URL, videoFormat: CMFormatDescription, videoBitrate: Int? = nil, audioFormat: CMFormatDescription? = nil) throws {
        
        let config = MovieFileConfig(url: fileURL,
                                     container: .mov,
                                     quality: .high,
                                     videoBitRate: videoBitrate,
                                     videoFormat: videoFormat,
                                     audioFormat: audioFormat)
        
        try super.init(config)
    }
    
}
