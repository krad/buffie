import Foundation
import AVFoundation

enum FragmentedMP4WriterError: Error {
    case fileNotDirectory
    case directoryDoesNotExist
}

class FragmentedMP4Writer {
    
    var outputDir: URL
    var videoEncoder: VideoEncoder?
    var encodedVideoSamples: [CMSampleBuffer] = []
    var currentSegment = 0
    
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
    
    func got(_ sample: CMSampleBuffer) {
        self.videoEncoder?.encode(sample)
    }
    
}

extension FragmentedMP4Writer: VideoEncoderDelegate {
    
    func encoded(videoSample: CMSampleBuffer) {
        self.encodedVideoSamples.append(videoSample)
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

// TODO: Use this when the time is right.
//if let videoBytes = bytes(from: videoSample) {
//    let iterator = NALUStreamIterator(streamBytes: videoBytes, currentIdx: 0)
//    for nalu in iterator {
//        print(nalu)
//    }
//}
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
