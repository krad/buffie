struct STBL: BinaryEncodable {
    
    let type: Atom = .stbl
    
    var sampleDescriptionAtom = STSD()
    var timeToSampleAtom      = STTS()
//    var compositionOffsetAtom = CTTS()
//    var compositionShiftLeastGreatestAtom = CSLG()
//    var syncSampleAtom = STSS()
//    var partialSyncSampleAtom = STPS()
    var sampleToChunkAtom   = STSC()
    var sampleSizeAtom      = STSZ()
    var chunkOffsetAtom     = STCO()
//    var shadowSyncAtom = STSH()
//    var sampleGroupDescriptionAtom = SGPD()
//    var sampleToGroupAtom = SBGP()
//    var sampleDependenyFlagAtom = SDTP()
    
}
