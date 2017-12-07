import Foundation

protocol AVMuxedStreamDelegate {
    func packetized(payload: [UInt8])
}

public class AVMuxedStreamBuilder: AVMuxerDelegate {
    private var delegate: AVMuxedStreamDelegate
    
    init(delegate: AVMuxedStreamDelegate) {
        self.delegate = delegate
    }
    
    final public func got(paramSet: [[UInt8]]) {
        var payload: [UInt8] = []
        for params in paramSet { payload += AVMuxer.streamDelimeter + [AVMuxer.paramSetMarker] + params }
        self.delegate.packetized(payload: payload)
    }
    
    final public func muxed(data: [UInt8]) {
        let payload = AVMuxer.streamDelimeter + data
        self.delegate.packetized(payload: payload)
    }
}
