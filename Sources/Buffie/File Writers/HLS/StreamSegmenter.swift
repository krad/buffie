import Foundation
import CoreMedia

struct StreamContents: OptionSet {
    var rawValue: UInt8
    
    init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
    
    static let video = StreamContents(rawValue: 1 << 0)
    static let audio = StreamContents(rawValue: 1 << 1)
    
}

class StreamSegmenter {
    
    var outputDir: URL
    var targetSegmentDuration: Double
    var streamContents: StreamContents
    
    var playlistWriter: HLSPlaylistWriter
    var initSegmentWriter: FragementedMP4InitalizationSegment?
    var currentSegmentWriter: FragmentedMP4Segment?
    
    var currentSegment = 0
    
    var moovConfig = MOOVConfig()
    
    var currentSegmentName: String {
        return "fileSeq\(self.currentSegment).mp4"
    }
    
    var currentSegmentURL: URL {
        return self.outputDir.appendingPathComponent(self.currentSegmentName)
    }
    
    init(outputDir: URL, targetSegmentDuration: Double, streamContents: StreamContents = [.video]) throws {
        self.outputDir             = outputDir
        self.targetSegmentDuration = targetSegmentDuration
        self.streamContents        = streamContents
        
        let playlistURL     = self.outputDir.appendingPathComponent("prog_index.m3u8")
        self.playlistWriter = try HLSPlaylistWriter(playlistURL)
    }
    
    func readyForMOOV() -> Bool {
        if self.streamContents == [.video, .audio] {
            if let _ = self.moovConfig.videoSettings {
                if let _ = self.moovConfig.audioSettings {
                    return true
                }
            }
        }
        
        if self.streamContents == [.video] {
            if let _ = self.moovConfig.videoSettings {
                return true
            }
        }
        
        if self.streamContents == [.audio] {
            if let _ = self.moovConfig.audioSettings {
                return true
            }
        }
        
        return false
    }
    
    func updateMOOVConfig(with sample: Sample) {
        if sample.type == .video {
            if let videoSample = sample as? VideoSample {
                var videoConfig               = MOOVVideoSettings(videoSample.format)
                videoConfig.timescale         = UInt32(videoSample.timescale)
                self.moovConfig.videoSettings = videoConfig
            }
        }
        
        if sample.type == .audio {
            if let audioSample = sample as? AudioSample {
                let audioConfig = MOOVAudioSettings(audioSample)
                self.moovConfig.audioSettings = audioConfig
            }
        }
    }
    
    func newInitialSegment(with sample: Sample) {
        guard self.readyForMOOV() else { return }
        
        do {
            self.initSegmentWriter = try FragementedMP4InitalizationSegment(self.currentSegmentURL,
                                                                            config: self.moovConfig)
            self.playlistWriter.writerHeader(with: self.targetSegmentDuration)
            self.currentSegment += 1
            
//            self.handleSegment(with: sample as! VideoSample)
        }
        catch { print("=== Couldn't write init segment") }
    }
    
    func newSegment(with sample: VideoSample) {
        do {
            var currentSequence = 1
            if let csw = self.currentSegmentWriter {
                currentSequence = csw.currentSequence
            }
            
            self.currentSegmentWriter = try FragmentedMP4Segment(self.currentSegmentURL,
                                                                 config: self.moovConfig,
                                                                 segmentNumber: self.currentSegment,
                                                                 currentSequence: currentSequence)
            
            self.currentSegmentWriter?.append(sample)
        }
        catch { }
    }
    
    func splitSegmentSamples(in writer: FragmentedMP4Segment, with sample: VideoSample) {
        
        let nextDuration = Double(sample.durationSeconds + writer.duration)
        
        if nextDuration <= self.targetSegmentDuration {
            
            writer.append(sample)
            
        } else {
            
            try? writer.write()
            self.playlistWriter.write(segment: writer)
            
            self.currentSegment += 1
            self.newSegment(with: sample)
            
        }
    }
    
    public func append(_ sample: VideoSample) {
        self.updateMOOVConfig(with: sample)

        if let _ = self.initSegmentWriter {
            self.handleSegment(with: sample)
        } else {
            self.newInitialSegment(with: sample)
        }
    }
    
    public func append(_ sample: AudioSample) {
//        self.updateMOOVConfig(with: sample)
//        if let _ = self.initSegmentWriter {
//            if let currentSegment = self.currentSegmentWriter {
//                currentSegment.append(sample)
//            }
//        } else {
////            self.newInitialSegment(with: sample)
//        }
    }

    func handleSegment(with sample: VideoSample) {
        if let writer = self.currentSegmentWriter {
            self.splitSegmentSamples(in: writer, with: sample)
        } else {
            self.newSegment(with: sample)
        }
    }
    
}
