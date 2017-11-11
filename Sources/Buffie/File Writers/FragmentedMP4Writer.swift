import Foundation
import AVFoundation

enum FragmentedMP4WriterError: Error {
    case fileNotDirectory
    case directoryDoesNotExist
}

class FragmentedMP4Writer {
    
    var outputDir: URL
    var videoEncoder: VideoEncoder?
    var currentSegment = 0
    
    var currentSegmentWriter: FragmentedMP4Segment?
    
    var duration: Int64 = 0
    
    internal var samples: [Sample] = []

    var currentSegmentName: String {
        return "fileSeq\(self.currentSegment).mp4"
    }
    
    var currentSegmentURL: URL {
        return self.outputDir.appendingPathComponent(self.currentSegmentName)
    }
    
    init(_ outputDir: URL) throws {
        
        /// Verify we have a directory to write to
        var isDir: ObjCBool = false
        let pathExists      = FileManager.default.fileExists(atPath: outputDir.path, isDirectory: &isDir)
        if !isDir.boolValue { throw FragmentedMP4WriterError.fileNotDirectory }
        if !pathExists      { throw FragmentedMP4WriterError.directoryDoesNotExist }
        self.outputDir = outputDir
        
        /// Setup a video encoder
        var settings                  = VideoEncoderSettings()
        settings.allowFrameReordering = false
        settings.profileLevel         = .h264High_4_0
        self.videoEncoder = try VideoEncoder(settings, delegate: self)
        
    }
    
    func setupInitial(with sample: Sample) {
        do {
            _ = try FragementedMP4InitalizationSegment(self.currentSegmentURL,
                                                       format: sample.format,
                                                       sample: sample)
            self.currentSegment += 1
        }
        catch { print("=== Couldn't write init segment") }
    }
    
    func setupSegment() {
        do {
            self.currentSegmentWriter = try FragmentedMP4Segment(self.currentSegmentURL,
                                                                 segmentNumber: self.currentSegment)
        }
        catch { }
    }
    
    func got(_ sample: CMSampleBuffer) {
        self.videoEncoder?.encode(sample)
    }
    
    func append(_ sample: Sample) {
        self.duration += sample.duration.value
        
        if self.currentSegment == 0 {
            self.setupInitial(with: sample)
            self.samples = [sample]
        } else {
            
            if let writer = self.currentSegmentWriter {
                if sample.isSync {
                    if samples.count > 0 { try? writer.write(samples) }
                    self.samples = [sample]
                } else {
                    self.samples.append(sample)
                }
                
            } else {
                self.samples.append(sample)
                setupSegment()
            }
            
        }
    }
    
}

extension FragmentedMP4Writer: VideoEncoderDelegate {
    
    func encoded(videoSample: CMSampleBuffer) {
        if let videoBytes = bytes(from: videoSample) {
            var sample   = Sample(sampleBuffer: videoSample)
            for nalu in NALUStreamIterator(streamBytes: videoBytes, currentIdx: 0) {
                sample.nalus.append(nalu)
            }
            self.append(sample)
        }
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
    var currentSequence: Int = 0
    
    init(_ file: URL, segmentNumber: Int) throws {
        self.file          = file
        
        if !FileManager.default.fileExists(atPath: file.path) {
            FileManager.default.createFile(atPath: file.path, contents: nil, attributes: nil)
        }
        
        self.fileHandle    = try FileHandle(forWritingTo: file)
        self.segmentNumber = segmentNumber
    }
    
    func write(_ samples: [Sample]) throws {
        
        let moof = MOOF(samples: samples,
                        currentSequence: UInt32(self.currentSequence))
        
        let mdat = MDAT(samples: samples)
        
        let moofBytes = try BinaryEncoder.encode(moof)
        let mdatBytes = try BinaryEncoder.encode(mdat)

        let data = Data(bytes: moofBytes + mdatBytes)
        self.fileHandle.write(data)
        
        self.currentSequence += 1
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
        
        if let sampleAttachements = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, false) as? [Any] {
            if let attachments = sampleAttachements.first as? [CFString: Any] {
                if let notSync         = attachments[kCMSampleAttachmentKey_NotSync] as? Bool                    { self.isSync = !notSync } else { self.isSync = true }
                if let dependsOnOthers = attachments[kCMSampleAttachmentKey_DependsOnOthers] as? Bool            { self.dependsOnOthers = dependsOnOthers }
                if let earlierPTS      = attachments[kCMSampleAttachmentKey_EarlierDisplayTimesAllowed] as? Bool { self.earlierDisplayTimesAllowed = earlierPTS }
            }
        }
    }
    
}

public struct NALUStreamIterator: Sequence, IteratorProtocol {
    
    let streamBytes: [UInt8]
    var currentIdx: Int = 0
    
    mutating public func next() -> NALU? {
        guard self.currentIdx < streamBytes.count else { return nil }
        
        if let naluSize = UInt32(bytes: Array(streamBytes[currentIdx..<currentIdx+4])) {
            let nextIdx = currentIdx + Int(naluSize) + 4
            
            let naluData = Array(streamBytes[currentIdx..<nextIdx])
            let nalu     = NALU(data: naluData)

            self.currentIdx += nextIdx
            return nalu
        }
        
        return nil
    }
    
}

func fourCharCode(from str: String) -> FourCharCode {
    var string = str
    if string.unicodeScalars.count < 4 {
        string = str + "    "
    }
    
    //string = string.substringToIndex(string.startIndex.advancedBy(4))
    
    var res:FourCharCode = 0
    for unicodeScalar in string.unicodeScalars {
        res = (res << 8) + (FourCharCode(unicodeScalar) & 255)
    }
    
    return res
}
