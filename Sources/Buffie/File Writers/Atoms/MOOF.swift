import Foundation

struct MOOF: BinaryEncodable {
    
    let type: Atom = .moof
    
    var movieFragmentHeaderAtom: [MFHD] = [MFHD()]
    var trackFragments: [TRAF] = [TRAF()]
    
    init(samples: [Sample], currentSequence: UInt32)
    {
        self.movieFragmentHeaderAtom = [MFHD(sequenceNumber: currentSequence)]
        self.trackFragments          = [TRAF(samples: samples)]
    }
    
    func binaryEncode(to encoder: BinaryEncoder) throws {
        // Pre encode so we can get size and calculate offset :-/
        let newEncoder = BinaryEncoder()
        try newEncoder.encode(self.type)
        try newEncoder.encode(self.movieFragmentHeaderAtom)
        try newEncoder.encode(self.trackFragments)
        
        try encoder.encode(self.type)
        try encoder.encode(self.movieFragmentHeaderAtom)
        
        let padding = 4 + 4 + 4 // 32bits for moof size, 32bits for mdat size, 32 bits for mdat tag
        if var traf = self.trackFragments.first {
            if var trun = traf.trackRun.first {
                trun.dataOffset = Int32(newEncoder.data.count + padding)
                traf.trackRun = [trun]
            }
            try encoder.encode([traf])
        }
    }
    
    
}

