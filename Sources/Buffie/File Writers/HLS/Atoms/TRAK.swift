struct TRAK: BinarySizedEncodable {
    
    let type: Atom = .trak
    
    var trackHeader: [TKHD] = [TKHD()]
    var mediaAtom: [MDIA]   = [MDIA()]
    
    static func from(_ config: MOOVConfig) -> TRAK {
        var trak         = TRAK()
        trak.trackHeader = [TKHD.from(config)]
        trak.mediaAtom   = [MDIA.from(config: config)]
        return trak
    }
    
    
}
