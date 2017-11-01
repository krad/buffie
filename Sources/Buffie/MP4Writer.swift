import Foundation
import AVFoundation

public class MP4Writer: MovieFileWriter {

    public init(_ fileURL: URL, videoFormat: CMFormatDescription, audioFormat: CMFormatDescription? = nil) throws {
        try super.init(fileType: .mp4, fileURL: fileURL, videoFormat: videoFormat, audioFormat: audioFormat)
    }
    
}

public class MOVWriter: MovieFileWriter {

    public init(_ fileURL: URL, videoFormat: CMFormatDescription, audioFormat: CMFormatDescription? = nil) throws {
        try super.init(fileType: .mov, fileURL: fileURL, videoFormat: videoFormat, audioFormat: audioFormat)
    }
    
}

public class M4VWriter: MovieFileWriter {
    
    public init(_ fileURL: URL, videoFormat: CMFormatDescription, audioFormat: CMFormatDescription? = nil) throws {
        try super.init(fileType: .m4v, fileURL: fileURL, videoFormat: videoFormat, audioFormat: audioFormat)
    }
    
}
