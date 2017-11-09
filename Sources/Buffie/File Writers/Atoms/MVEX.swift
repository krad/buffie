struct MVEX: BinaryEncodable {
    
    let type: Atom = .mvex
    var trackExAtoms: [TREX] = [TREX()]
    
}
