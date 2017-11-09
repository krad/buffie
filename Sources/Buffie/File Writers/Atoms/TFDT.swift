// Track Fragment Decode time
struct TFDT: BinarySizedEncodable {
    
    let type: Atom = .tfdt
    var version: UInt8 = 1
    var flags: [UInt8] = [0, 0, 0]
    
    var decodeTime: UInt64 = 300000
    
}
