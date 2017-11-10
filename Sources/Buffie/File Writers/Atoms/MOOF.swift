struct MOOF: BinaryEncodable {
    
    let type: Atom = .moof
    
    var movieFragmentHeaderAtom: [MFHD] = [MFHD()]
    var trackFragments: [TRAF] = [TRAF()]
    
    
}
