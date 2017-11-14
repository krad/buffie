import Foundation
import CoreMedia

class StreamSegmenter {
    
    var outputDir: URL
    var targetSegmentDuration: Double
    
    var playlistWriter: HLSPlaylistWriter
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
    
    func setupInitial(with sample: Sample) {
        do {
            _ = try FragementedMP4InitalizationSegment(self.currentSegmentURL,
                                                       format: sample.format,
                                                       sample: sample)
            self.playlistWriter.writerHeader(with: self.targetSegmentDuration)
            self.currentSegment += 1
        }
        catch { print("=== Couldn't write init segment") }
    }
    
    func setupSegment(with sample: Sample) {
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
        if Int(CMTimeGetSeconds(writer.duration)) >= Int(self.targetSegmentDuration) {
            try? writer.write()
            self.playlistWriter.write(segment: writer)
            
            self.currentSegment += 1
            self.setupSegment(with: sample)
        } else {
            writer.append(sample)
        }
    }
    
    public func append(_ sample: Sample) {
        if self.currentSegment == 0 {
            self.handleHeader(with: sample)
            self.handleSegment(with: sample)
        } else {
            self.handleSegment(with: sample)
        }
    }

    func handleHeader(with sample: Sample) {
        self.setupInitial(with: sample)
    }
    
    func handleSegment(with sample: Sample) {
        if let writer = self.currentSegmentWriter {
            self.splitSegmentSamples(in: writer, with: sample)
        } else {
            setupSegment(with: sample)
        }
    }
    
}
