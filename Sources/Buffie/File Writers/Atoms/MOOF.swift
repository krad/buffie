struct MOOF: BinaryEncodable {
    
    let type: Atom = .moof
    
    var movieFragmentHeaderAtom: [MFHD] = [MFHD()]
    var trackFragments: [TRAF] = [TRAF()]
    
    init(samples: [Sample], currentSequence: UInt32) {
        self.movieFragmentHeaderAtom = [MFHD(sequenceNumber: currentSequence)]
        self.trackFragments          = [TRAF(samples: samples)]
    }
    
}

