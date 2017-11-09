struct MVEX: BinarySizedEncodable {
    
    let type: Atom = .mvex
    var trackExAtoms: [TREX] = [TREX()]
    
}
