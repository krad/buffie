struct TRAK: BinarySizedEncodable {
    
    let type: Atom = .trak
    
    var trackHeader: [TKHD] = [TKHD()]
    var mediaAtom: [MDIA]   = [MDIA()]
    
}
