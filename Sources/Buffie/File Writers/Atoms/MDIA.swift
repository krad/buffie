struct MDIA: BinaryEncodable {
    
    let type: Atom = .mdia
    
    let mediaHeaderAtom = MDHD()
    let handlerReferenceAtom = HDLR()
    let mediaInformationAtom = MINF()
    
}
