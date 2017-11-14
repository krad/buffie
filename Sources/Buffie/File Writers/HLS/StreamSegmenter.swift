import Foundation
import CoreMedia

class StreamSegmenter {
    
    var outputDir: URL
    var targetSegmentDuration: Double
    
    var playlistWriter: HLSPlaylistWriter
    var initSegmentWriter: FragementedMP4InitalizationSegment?
    var currentSegmentWriter: FragmentedMP4Segment?
    
    var currentSegment = 0
    
    var currentSegmentName: String {
        return "fileSeq\(self.currentSegment).mp4"
    }
    
    var currentSegmentURL: URL {
        return self.outputDir.appendingPathComponent(self.currentSegmentName)
    }
    
    init(outputDir: URL, targetSegmentDuration: Double) throws {
        self.outputDir             = outputDir
        self.targetSegmentDuration = targetSegmentDuration
        
        let playlistURL     = self.outputDir.appendingPathComponent("prog_index.m3u8")
        self.playlistWriter = try HLSPlaylistWriter(playlistURL)
    }
    
    func newInitialSegment(with sample: Sample) {
        do {
            self.initSegmentWriter = try FragementedMP4InitalizationSegment(self.currentSegmentURL,
                                                                            videoFormat: sample.format,
                                                                            sample: sample)
            self.playlistWriter.writerHeader(with: self.targetSegmentDuration)
            self.currentSegment += 1
        }
        catch { print("=== Couldn't write init segment") }
    }
    
    func newSegment(with sample: Sample) {
        do {
            var currentSequence = 1
            if let csw = self.currentSegmentWriter {
                currentSequence = csw.currentSequence
            }
            
            self.currentSegmentWriter = try FragmentedMP4Segment(self.currentSegmentURL,
                                                                 segmentNumber: self.currentSegment,
                                                                 currentSequence: currentSequence)
            
            self.currentSegmentWriter?.append(sample)
        }
        catch { }
    }
    
    func splitSegmentSamples(in writer: FragmentedMP4Segment, with sample: Sample) {
        
        let nextDuration = CMTimeGetSeconds(CMTimeAdd(sample.duration, writer.duration))
        
        if nextDuration <= self.targetSegmentDuration {
            
            writer.append(sample)
            
        } else {
            
            try? writer.write()
            self.playlistWriter.write(segment: writer)
            
            self.currentSegment += 1
            self.newSegment(with: sample)
            
        }
    }
    
    public func append(_ sample: Sample) {
        if let _ = self.initSegmentWriter {
            self.handleSegment(with: sample)
        } else {
            self.newInitialSegment(with: sample)
            self.handleSegment(with: sample)
        }
    }
    
    public func append(_ audioBufferList: AudioBufferList) {
        if let _ = self.initSegmentWriter {
            
        }
    }

    func handleSegment(with sample: Sample) {
        if let writer = self.currentSegmentWriter {
            self.splitSegmentSamples(in: writer, with: sample)
        } else {
            self.newSegment(with: sample)
        }
    }
    
}
