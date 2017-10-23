import Foundation
import CoreMedia

internal enum NALUType: Int {
    case sps         = 7
    case pps         = 8
    case nonIDRslice = 1
    case IDRslice    = 5
    case sei         = 6
}

public protocol AVDemuxerDelegate {
    func demuxed(sample: CMSampleBuffer, type: SampleType)
}

public class AVDemuxer {
    
    private var videoDecoder: VideoDecoder?
    private var delegate: AVDemuxerDelegate
    
    init(delegate: AVDemuxerDelegate) {
        self.delegate = delegate
    }
    
    func got(sampleFormatData: [[UInt8]]) {
        if let format = formatFrom(sampleFormatData) {
            self.videoDecoder = try? VideoDecoder(format: format, delegate: self)
        }
    }
    
    func demux(_ data: [UInt8]) {
        
    }
}

extension AVDemuxer: VideoDecoderDelegate {

    public func decoded(_ pixelBuffer: CVPixelBuffer, with pts: CMTime) {
        
    }

}

/// Strips the emulation bytes / delimeter from the stream and returns array of unsigned 8 bit integers
///
/// - Parameter data: Data starting with a stream delimter
/// - Returns: Array of 8 bit integers WITHOUT the delimeter.  Contains media type at byte 0
public func stripHeader(from data: Data) -> [UInt8] {
    let strippedData        = data[mediaStreamDelimeter.count...data.count]
    var buf                 = [UInt8](repeating: 0, count: strippedData.count)
    strippedData.copyBytes(to: &buf, count: strippedData.count)
    return buf
}


internal func formatFrom(_ bytes: [[UInt8]]) -> CMFormatDescription? {
    var status                  = noErr
    let ptrArray                = bytes.map { UnsafePointer<UInt8>($0) }
    let paramSetSizes: [size_t] = bytes.map { $0.count }
    var format: CMFormatDescription?
    status = CMVideoFormatDescriptionCreateFromH264ParameterSets(kCFAllocatorDefault,
                                                                 2,
                                                                 ptrArray,
                                                                 paramSetSizes,
                                                                 4,
                                                                 &format)
    if status != noErr { return nil }
    else { return format }
}

