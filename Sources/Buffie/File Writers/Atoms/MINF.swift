struct MINF: BinarySizedEncodable {
    
    let type: Atom = .minf
    var videoMediaInformationAtom: [VMHD] = [VMHD()]
    var dataInformationAtom: [DINF] = [DINF()]
    var sampleTableAtom: [STBL] = [STBL()]
    
}
