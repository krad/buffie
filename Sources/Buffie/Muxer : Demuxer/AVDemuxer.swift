import Foundation
import CoreMedia
import BoyerMoore

public protocol AVDemuxerDelegate {
    func got(sampleFormatData: [[UInt8]])
    func got(sample: [UInt8], sampleType: SampleType)
}

public class AVDemuxer {

    private var delegate: AVDemuxerDelegate
    private let q = DispatchQueue(label: "demuxer.q",
                                  qos: .default,
                                  attributes: .concurrent,
                                  autoreleaseFrequency: .inherit,
                                  target: nil)
    
    private var readBuffer: [UInt8] = [] { didSet { self.searchForPacket() } }
    private var params: [[UInt8]] = [] {
        didSet {
            if self.params.count == 2 { self.delegate.got(sampleFormatData: self.params) }
        }
    }

    public init(delegate: AVDemuxerDelegate) {
        self.delegate = delegate
    }
    
    final public func received(bytes: [UInt8]) {
        q.async(flags: .barrier) { self.readBuffer.append(contentsOf: bytes) }
    }
    
    internal func searchForPacket() {
        q.async(flags: .barrier) {
            var rangesToRemove: [Range<Int>] = []
            for chunk in self.readBuffer.chunk(with: AVMuxer.streamDelimeter, includeSeperator: true) {
                // strip the media deliminator
                let packet = Array(chunk[chunk.startIndex+4..<chunk.endIndex])
                self.demux(packet)
                
                // Add range to remove so we can slim the buffer of processed data
                rangesToRemove.append(Range(chunk.startIndex..<chunk.endIndex))
            }

            // Remove ranges from the buffer
            for range in rangesToRemove.reversed() { self.readBuffer.removeSubrange(range) }
        }
    }
    
    internal func demux(_ data: [UInt8]) {
        let payload = Array(data[1..<data.count])
        if let sampleType = SampleType(rawValue: data[0]) {
            self.delegate.got(sample: payload, sampleType: sampleType)
        } else {
            if data[0] == AVMuxer.paramSetMarker {
                self.params.append(payload)
            }
        }
    }
}

/// Creates a format description from an array of bytes (SPS & PPS)
///
/// - Parameter bytes: Array of UInt8 arrays representing info from the AVC header
/// - Returns: A CMFormatDescription
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

extension Data {
    
    
    
}
