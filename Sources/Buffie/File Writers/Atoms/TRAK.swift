struct TRAK: BinaryEncodable {
    
    let type: Atom = .trak
    
    var trackHeader = TKHD()
    var mediaAtom   = MDIA()
    
}
