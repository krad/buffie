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

    var samples: [Sample] = [] {
        didSet {
            guard samples.count > 0 else { return }
            if samples.count % 10 == 0 {
                self.writeSamples()
            }
        }
    }

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
        let settings      = VideoEncoderSettings()
        self.videoEncoder = try VideoEncoder(settings, delegate: self)
        
    }
    
    func writeSamples() {
        if self.currentSegment == 0 {
            self.setupInitial()
        } else {
            let segmentSamples = Array(self.samples[0..<10])
            self.setupSegment(segmentSamples)
        }
        self.currentSegment += 1
    }
    
    func setupInitial() {
        if let sample = samples.first {
            do {
                _ = try FragementedMP4InitalizationSegment(self.currentSegmentURL,
                                                           format: sample.format)
            }
            catch { print("=== Couldn't write init segment") }
        }
    }
    
    func setupSegment(_ samples: [Sample]) {
        do {
            _ = try FragmentedMP4Segment(self.currentSegmentURL,
                                         samples: samples,
                                         segmentNumber: self.currentSegment)
        }
        catch { }
    }
    
    func got(_ sample: CMSampleBuffer) {
        self.videoEncoder?.encode(sample)
    }
    
}

extension FragmentedMP4Writer: VideoEncoderDelegate {
    
    func encoded(videoSample: CMSampleBuffer) {
        if let videoBytes = bytes(from: videoSample) {
            var sample   = Sample(sampleBuffer: videoSample)
            for nalu in NALUStreamIterator(streamBytes: videoBytes, currentIdx: 0) {
                sample.nalus.append(nalu)
            }
            self.samples.append(sample)
        }
    }
    
}

class FragementedMP4InitalizationSegment {
    
    init(_ file: URL, format: CMFormatDescription) throws {
        let ftypBytes = try BinaryEncoder.encode(FTYP())
        let moovBytes = try BinaryEncoder.encode(MOOV())
        
        let data = Data(bytes: ftypBytes + moovBytes)
        try data.write(to: file)
    }
}

class FragmentedMP4Segment {
    
    var segmentNumber: Int = 0
    var currentSequence: Int = 1
    
    init(_ file: URL, samples: [Sample], segmentNumber: Int) throws {
        self.segmentNumber = segmentNumber
        
        let moof = try BinaryEncoder.encode(MOOF(samples: samples,
                                                 currentSequence: UInt32(self.currentSequence)))
        
        let mdat = try BinaryEncoder.encode(MDAT(samples: samples))
        
        let data = Data(bytes: moof + mdat)
        try data.write(to: file)
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
        return self.nalus.reduce(0, { last, nalu in last + nalu.size })
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
                if let dependsOnOthers = attachments[kCMSampleAttachmentKey_DependsOnOthers] as? Bool            { self.dependsOnOthers = dependsOnOthers }
                if let notSync         = attachments[kCMSampleAttachmentKey_NotSync] as? Bool                    { self.isSync = !notSync }
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
            let nalu = NALU(data: Array(streamBytes[currentIdx..<nextIdx]))
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
