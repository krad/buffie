struct MDIA: BinarySizedEncodable {
    
    let type: Atom = .mdia
    
    var mediaHeaderAtom: [MDHD] = [MDHD()]
    var handlerReferenceAtom: [HDLR] = [HDLR()]
    var mediaInformationAtom: [MINF] = [MINF()]
    
    static func from(config: MOOVConfig) -> MDIA {
        var mdia = MDIA()
        mdia.mediaHeaderAtom      = [MDHD.from(config)]
        mdia.mediaInformationAtom = [MINF.from(config)]
        return mdia
    }
    
}
