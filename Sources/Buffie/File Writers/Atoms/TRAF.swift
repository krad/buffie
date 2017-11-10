struct TRAF: BinarySizedEncodable {
    
    let type: Atom = .traf
    
    var trackFragmentHeader: [TFHD] = [TFHD()]
    var trackDecodeTimeAtom: [TFDT] = [TFDT()]
    var trackRun: [TRUN] = [TRUN()]
    
    init(samples: [Sample] = []) {
        if let sample = samples.first {
            self.trackFragmentHeader = [TFHD.from(sample: sample)]
            self.trackDecodeTimeAtom = [TFDT.from(sample: sample)]
            self.trackRun            = [TRUN.from(samples: samples)]
        }
    }
    
}
