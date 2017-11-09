struct MDIA: BinarySizedEncodable {
    
    let type: Atom = .mdia
    
    let mediaHeaderAtom: [MDHD] = [MDHD()]
    let handlerReferenceAtom: [HDLR] = [HDLR()]
    let mediaInformationAtom: [MINF] = [MINF()]
    
}
