struct MOOV: BinaryEncodable {
    
    let type: Atom = .moov
    
    var movieHeaderAtom = MVHD()
    var tracks: [TRAK] = [TRAK()]
    
    var mediaFragmentInfo = MVEX()
    
}
