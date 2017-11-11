// Track Fragment Decode time
struct TFDT: BinarySizedEncodable {
    
    let type: Atom      = .tfdt
    var version: UInt8  = 1
    var flags: [UInt8]  = [0, 0, 0]
    
    var decodeTime: UInt64 = 300000
    
    static func from(sample: Sample) -> TFDT {
        var tfdt        = TFDT()
        tfdt.decodeTime = UInt64(sample.decode.timescale)
        return tfdt
    }
    
}
