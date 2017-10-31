import Buffie


class MuxerDelegate: AVMuxerDelegate {
    
    func got(paramSet: [[UInt8]]) {
        
    }
    
    func muxed(data: [UInt8]) {
        
    }
}

let muxerDelegate = MuxerDelegate()
let muxer         = try AVMuxer(delegate: muxerDelegate)

let camera = Camera(.back, reader: muxer, controlDelegate: nil)


