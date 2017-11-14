// FIXME
struct STSD: BinarySizedEncodable {
    
    let type: Atom = .stsd
    var version: UInt8 = 0
    var flags: [UInt8] = [0, 0, 0]
    
    var numberOfEntries: UInt32 = 1
    var avc1: [AVC1] = [AVC1()]
    
    static func from(_ config: MOOVVideoSettings) -> STSD {
        var stsd = STSD()
        stsd.avc1 = [AVC1.from(config)]
        return stsd
    }
    
}
