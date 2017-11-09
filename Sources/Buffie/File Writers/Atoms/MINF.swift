struct MINF: BinaryEncodable {
    
    let type: Atom = .minf
    var videoMediaInformationAtom = VMHD()
    var dataInformationAtom       = DINF()
    var sampleTableAtom           = STBL()
    
}
