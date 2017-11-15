struct ESDS: BinarySizedEncodable {
    
    let type: Atom = .esds
    var version: UInt8 = 0
    var flags: [UInt8] = [0, 0, 0]
    
    var decoderConfig: UInt32 = 0x1210
    
    static func from(_ config: MOOVAudioSettings) -> ESDS {
        let esds = ESDS()
        return esds
    }
    
}
