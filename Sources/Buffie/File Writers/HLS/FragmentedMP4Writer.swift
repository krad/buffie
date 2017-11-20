import Foundation
import AVFoundation

public enum FragmentedMP4WriterError: Error {
    case fileNotDirectory
    case directoryDoesNotExist
}

public class FragmentedMP4Writer: StreamSegmenterDelegate {
    
    var segmenter: StreamSegmenter?
    var videoInput: FragmentedVideoInput?
    var audioInput: FragmentedAudioInput?
    var currentSegment: FragmentedMP4Segment?
    
    fileprivate var playerListWriter: HLSPlaylistWriter
    
    public init(_ outputDir: URL) throws {
        /// Verify we have a directory to write to
        var isDir: ObjCBool = false
        let pathExists      = FileManager.default.fileExists(atPath: outputDir.path, isDirectory: &isDir)
        if !isDir.boolValue { throw FragmentedMP4WriterError.fileNotDirectory }
        if !pathExists      { throw FragmentedMP4WriterError.directoryDoesNotExist }
        
        self.playerListWriter = try HLSPlaylistWriter(outputDir.appendingPathComponent("out.m3u8"),
                                                      playlistType: .vod)
        
        self.segmenter  = try StreamSegmenter(outputDir: outputDir,
                                              targetSegmentDuration: 6.0,
                                              delegate: self)
        
        self.videoInput = try FragmentedVideoInput() { sample in
            self.segmenter?.append(sample)
        }
        
        self.audioInput = try FragmentedAudioInput() { sample in
            self.segmenter?.append(sample)
        }
    }
    
    public func got(_ sample: CMSampleBuffer, type: SampleType) {
        switch type {
        case .video: self.videoInput?.append(sample)
        case .audio: self.audioInput?.append(sample)
        }
    }
    
    func writeInitSegment(with config: MOOVConfig) {
        _ = try? FragementedMP4InitalizationSegment(self.segmenter!.currentSegmentURL,
                                                    config: config)
        
        self.playerListWriter.writerHeader(with: self.segmenter!.targetSegmentDuration)
    }
    
    func createNewSegment(with segmentID: Int, and sequenceNumber: Int) {
        if let segment = self.currentSegment {
            self.playerListWriter.write(segment: segment)
        }
        
        self.currentSegment = try? FragmentedMP4Segment(self.segmenter!.currentSegmentURL,
                                                       config: self.segmenter!.moovConfig,
                                                       currentSequence: self.segmenter!.currentSequence)
    }
    
    func writeMOOF(with samples: [Sample], and duration: Double) {
        try? self.currentSegment?.write(samples, with: duration)
    }
    

    
}

