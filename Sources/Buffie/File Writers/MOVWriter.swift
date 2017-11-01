import Foundation
import AVFoundation

public class MOVWriter: MovieFileWriter {
    
    public init(_ fileURL: URL, videoFormat: CMFormatDescription, audioFormat: CMFormatDescription? = nil) throws {
        try super.init(fileType: .mov, fileURL: fileURL, videoFormat: videoFormat, audioFormat: audioFormat)
    }
    
}

