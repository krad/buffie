import Foundation
import AVFoundation

public enum FragmentedMP4WriterError: Error {
    case fileNotDirectory
    case directoryDoesNotExist
}

public class FragmentedMP4Writer {
    
    var outputDir: URL
    var videoEncoder: VideoEncoder?
    var currentSegment = 0
    
    var targetSegmentDuration = 6.0
    var currentSegmentWriter: FragmentedMP4Segment?
    
    var playlistWriter: HLSPlaylistWriter
    
    var currentSegmentName: String {
        return "fileSeq\(self.currentSegment).mp4"
    }
    
    var currentSegmentURL: URL {
        return self.outputDir.appendingPathComponent(self.currentSegmentName)
    }
    
    public init(_ outputDir: URL) throws {
        /// Verify we have a directory to write to
        var isDir: ObjCBool = false
        let pathExists      = FileManager.default.fileExists(atPath: outputDir.path, isDirectory: &isDir)
        if !isDir.boolValue { throw FragmentedMP4WriterError.fileNotDirectory }
        if !pathExists      { throw FragmentedMP4WriterError.directoryDoesNotExist }
        self.outputDir = outputDir
        
        /// Setup the playlist writer
        let playlistURL     = self.outputDir.appendingPathComponent("prog_index.m3u8")
        self.playlistWriter = try HLSPlaylistWriter(playlistURL)
        
        /// Setup a video encoder
        var settings                  = VideoEncoderSettings()
        settings.allowFrameReordering = false
        settings.frameRate            = 60
        settings.profileLevel         = .h264High_4_0
        self.videoEncoder             = try VideoEncoder(settings, delegate: self)
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
    
    public func got(_ sample: CMSampleBuffer) {
        self.videoEncoder?.encode(sample)
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
    
    func splitSegmentSamples(in writer: FragmentedMP4Segment, with sample: Sample) {
        if Int(writer.duration) >= Int(self.targetSegmentDuration) {
            try? writer.write()
            self.playlistWriter.write(segment: self.currentSegmentWriter!)
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
    
    
}

extension FragmentedMP4Writer: VideoEncoderDelegate {
    public func encoded(videoSample: CMSampleBuffer) {
        self.append(Sample(sampleBuffer: videoSample))
    }
}

class FragementedMP4InitalizationSegment {
    
    init(_ file: URL, format: CMFormatDescription, sample: Sample) throws {
        
        var config       = MOOVConfig(format)
        config.timescale = UInt32(sample.duration.timescale)
        
        let ftypBytes = try BinaryEncoder.encode(FTYP())
        let moovBytes = try BinaryEncoder.encode(MOOV(config))
        
        let data = Data(bytes: ftypBytes + moovBytes)
        try data.write(to: file)
    }
}

struct MOOVConfig {
    
    var sps: [UInt8]
    var pps: [UInt8]
    var width: UInt32
    var height: UInt32
    var timescale: UInt32 = 30000
    
    init(_ format: CMFormatDescription) {
        let paramSet = getVideoFormatDescriptionData(format)
        self.sps = paramSet.first!
        self.pps = paramSet.last!
        
        let dimensions = CMVideoFormatDescriptionGetDimensions(format)
        self.width     = UInt32(dimensions.width)
        self.height    = UInt32(dimensions.height)
    }
    
}


class FragmentedMP4Segment {
    
    // Current segment we're on.  Not even sure why this class knows about this
    var segmentNumber: Int = 0
    var file: URL
    var fileHandle: FileHandle

    /// Current moof we're on
    var currentSequence: Int
    
    var duration: Float64 = 0
    var cnt = 0
    
    var samples: [Sample] = []
    
    var prevDecodeTime: UInt64 = 0
    
    init(_ file: URL,
         segmentNumber: Int,
         currentSequence: Int = 1) throws
    {
        self.file          = file
        
        if !FileManager.default.fileExists(atPath: file.path) {
            FileManager.default.createFile(atPath: file.path, contents: nil, attributes: nil)
        }
        
        self.fileHandle      = try FileHandle(forWritingTo: file)
        self.segmentNumber   = segmentNumber
        self.currentSequence = currentSequence
    }
    
    func append(_ sample: Sample) {
        self.duration += CMTimeGetSeconds(sample.duration)
        if sample.isSync && self.samples.count > 0 {
            try? self.write()
            self.samples.append(sample)
        } else {
            self.samples.append(sample)
        }
    }
    
    func write() throws {
        let moof = MOOF(samples: samples,
                        currentSequence: UInt32(self.currentSequence),
                        prevDecodeTime: self.prevDecodeTime)
        
        let mdat = MDAT(samples: samples)
        
        let moofBytes = try BinaryEncoder.encode(moof)
        let mdatBytes = try BinaryEncoder.encode(mdat)
        
        let data = Data(bytes: moofBytes + mdatBytes)
        self.fileHandle.write(data)
    
        self.prevDecodeTime = UInt64(samples.reduce(kCMTimeZero) { (cnt, sample) in CMTimeAdd(cnt, sample.duration) }.value)
        self.currentSequence += 1
        self.samples = []
    }
    
}

public struct Sample {
    
    var type: SampleType
    var format: CMFormatDescription
    var nalus: [NALU] = []
    var duration: CMTime
    var pts: CMTime
    var decode: CMTime
    
    var size: UInt32 {
        return self.nalus.reduce(0, { last, nalu in last + nalu.totalSize })
    }
    
    var dependsOnOthers: Bool = false
    var isSync: Bool = false
    var earlierDisplayTimesAllowed: Bool = false
    
    init(sampleBuffer: CMSampleBuffer) {
        self.type       = .video
        self.format     = CMSampleBufferGetFormatDescription(sampleBuffer)!
        self.duration   = CMSampleBufferGetDuration(sampleBuffer)
        self.pts        = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        self.decode     = CMSampleBufferGetDecodeTimeStamp(sampleBuffer)
        
        self.isSync                     = !sampleBuffer.notSync
        self.dependsOnOthers            = sampleBuffer.dependsOnOthers
        self.earlierDisplayTimesAllowed = sampleBuffer.earlierPTS
        
        if let bytes = bytes(from: sampleBuffer) {
            for nalu in NALUStreamIterator(streamBytes: bytes, currentIdx: 0) {
                self.nalus.append(nalu)
            }
        }
    }
    
}
