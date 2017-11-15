import Foundation
import CoreMedia
//
//public protocol AVDemuxerDelegate {
//    func demuxed(sample: CVPixelBuffer, with pts: CMTime)
//    func demuxed(audioBufferList: AudioBufferList)
//}
//
//@available (macOS 10.11, iOS 5, *)
//public class AVDemuxer {
//
//    private var videoDecoder: VideoDecoder?
//    private var audioDecoder: AudioDecoder?
//
//    private var delegate: AVDemuxerDelegate
//    private var readBuffer: [UInt8] = []
//
//    init(delegate: AVDemuxerDelegate) throws {
//        self.delegate     = delegate
//        self.audioDecoder = try AudioDecoder(AudioEncoderDecoderSettings(.decoding), delegate: self)
//    }
//
//    func got(sampleFormatData: [[UInt8]]) {
//        if let format = formatFrom(sampleFormatData) {
//            self.videoDecoder = try? VideoDecoder(format: format, delegate: self)
//        }
//    }
//
//    func demux(_ data: [UInt8]) {
//        guard let sampleType = SampleType(rawValue: data[0]) else { return }
//
//        let payload = Array(data[1..<data.count])
//
//        switch sampleType {
//        case .video:
//            self.videoDecoder?.decode(payload)
//        case .audio:
//            self.audioDecoder?.decode(payload)
//        }
//
//    }
//
//}
//
//@available (macOS 10.11, iOS 5, *)
//extension AVDemuxer: VideoDecoderDelegate {
//    public func decoded(_ pixelBuffer: CVPixelBuffer, with pts: CMTime) {
//        self.delegate.demuxed(sample: pixelBuffer, with: pts)
//    }
//}
//
//@available (macOS 10.11, iOS 5, *)
//extension AVDemuxer: AudioEncoderDecoderDelegate {
//    public func processed(_ audioBuffer: AudioBufferList) {
//        self.delegate.demuxed(audioBufferList: audioBuffer)
//    }
//}
//

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

