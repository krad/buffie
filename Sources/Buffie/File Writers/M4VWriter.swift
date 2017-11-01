import Foundation
import AVFoundation

public class M4VWriter: MovieFileWriter {
    
    public init(_ fileURL: URL, videoFormat: CMFormatDescription, audioFormat: CMFormatDescription? = nil) throws {
        try super.init(fileType: .m4v, fileURL: fileURL, videoFormat: videoFormat, audioFormat: audioFormat)
    }
    
}
