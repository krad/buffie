struct TREX: BinarySizedEncodable {
    
    let type: Atom = .trex
    
    var version: UInt8 = 0
    var flags: [UInt8] = [0, 0, 0]
    
    var trackID: UInt32 = 1
    var sampleDescriptionIndex: UInt32 = 1
    var sampleDuration: UInt32 = 0
    var sampleSize: UInt32 = 0
    
    var sampleFlags: UInt32 = 0x1010000 // I don't know what this is.

}
