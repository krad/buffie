import Foundation
import AVFoundation

public class MP4Writer: MovieFileWriter {

    public init(_ fileURL: URL, videoFormat: CMFormatDescription, audioFormat: CMFormatDescription? = nil) throws {
        try super.init(fileType: .mp4, fileURL: fileURL, videoFormat: videoFormat, audioFormat: audioFormat)
    }
    
}