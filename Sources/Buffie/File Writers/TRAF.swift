struct TRAF: BinarySizedEncodable {
    
    let type: Atom = .traf
    
    var trackFragmentHeader: [TFHD] = [TFHD()]
    var trackDecodeTimeAtom: [TFDT] = [TFDT()]
    var trackRun: [TRUN] = [TRUN()]
    
}
