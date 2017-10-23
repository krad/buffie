import Foundation
import VideoToolbox

public enum VideoDecoderError: Error {
    case couldNotBuildSession
}

public protocol VideoDecoderDelegate {
 func decoded(_ pixelBuffer: CVPixelBuffer, with pts: CMTime)
}

public class VideoDecoder {
    
    fileprivate var session: VTDecompressionSession?
    private var sessionCallbackRecord = VTDecompressionOutputCallbackRecord()
    private let sessionCallback: VTDecompressionOutputCallback = { outputRef, _, status, _, imgBuffer, pts, _ in
        let decoder: VideoDecoder = unsafeBitCast(outputRef, to: VideoDecoder.self)
        if status == noErr {
            if let img = imgBuffer {
                decoder.delegate.decoded(img, with: pts)
            }
        }
    }
    
    private let decodeFlags: VTDecodeFrameFlags = [VTDecodeFrameFlags._EnableTemporalProcessing, VTDecodeFrameFlags._EnableAsynchronousDecompression]
    private var decodeInfoFlags: VTDecodeInfoFlags = VTDecodeInfoFlags(rawValue: 0)
    
    var delegate: VideoDecoderDelegate
    
    init(format: CMVideoFormatDescription, delegate: VideoDecoderDelegate) throws {
        self.delegate = delegate
        
        self.sessionCallbackRecord.decompressionOutputCallback = self.sessionCallback
        self.sessionCallbackRecord.decompressionOutputRefCon   = unsafeBitCast(self, to: UnsafeMutableRawPointer.self)
        
        let decodeParams: [String: Any]        = [:]
        let dstPixelBufferAttrs: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA)]
        
        var status = noErr
        status = VTDecompressionSessionCreate(kCFAllocatorDefault,
                                              format,
                                              decodeParams as CFDictionary,
                                              dstPixelBufferAttrs as CFDictionary,
                                              &self.sessionCallbackRecord,
                                              &self.session)
        
        if status != noErr {
            throw VideoDecoderError.couldNotBuildSession
        }
    }
    
    func decode(sample: CMSampleBuffer) {
        if let session = self.session {
            var status = noErr
            status = VTDecompressionSessionDecodeFrame(session,
                                                       sample,
                                                       self.decodeFlags,
                                                       nil,
                                                       &self.decodeInfoFlags)
            if status != noErr {
                print(#function, "Error decoding frame:", status)
            }

        }
    }
    
}
