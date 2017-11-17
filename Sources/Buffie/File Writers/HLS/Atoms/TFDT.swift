// Track Fragment Decode time
struct TFDT: BinarySizedEncodable {
    
    let type: Atom      = .tfdt
    var version: UInt8  = 1
    var flags: [UInt8]  = [0, 0, 0]
    
    var baseMediaDecodeTime: UInt64 = 0
    var trackFragmentDuration: UInt64?
    
    static func from(decode: UInt64, duration: UInt64) -> TFDT {
        var tfdt                   = TFDT()
        tfdt.baseMediaDecodeTime   = decode
        tfdt.trackFragmentDuration = duration
        return tfdt
    }
    
    static func from(size: UInt32, sampleRate: UInt32) -> TFDT {
        var tfdt = TFDT()
        tfdt.baseMediaDecodeTime   = 0
        tfdt.trackFragmentDuration = nil
        return tfdt
    }
    
}
