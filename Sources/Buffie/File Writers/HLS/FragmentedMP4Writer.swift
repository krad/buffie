import Foundation
import AVFoundation

public enum FragmentedMP4WriterError: Error {
    case fileNotDirectory
    case directoryDoesNotExist
}

public class FragmentedMP4Writer {
    
    var segmenter: StreamSegmenter
    var videoInput: FragmentedVideoInput?
    
    public init(_ outputDir: URL) throws {
        /// Verify we have a directory to write to
        var isDir: ObjCBool = false
        let pathExists      = FileManager.default.fileExists(atPath: outputDir.path, isDirectory: &isDir)
        if !isDir.boolValue { throw FragmentedMP4WriterError.fileNotDirectory }
        if !pathExists      { throw FragmentedMP4WriterError.directoryDoesNotExist }
        
        self.segmenter  = try StreamSegmenter(outputDir: outputDir, targetSegmentDuration: 6.0)
        self.videoInput = try FragmentedVideoInput() { sample in
            self.segmenter.append(sample)
        }
    }
    
    
    public func got(_ sample: CMSampleBuffer, type: SampleType) {
        switch type {
        case .video: self.videoInput?.append(sample)
        default: print("")
        }
    }
    
    
}

