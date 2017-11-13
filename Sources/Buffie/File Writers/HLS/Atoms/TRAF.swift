import CoreMedia

struct TRAF: BinarySizedEncodable {
    
    let type: Atom = .traf
    
    var trackFragmentHeader: [TFHD] = [TFHD()]
    var trackDecodeAtom: [TFDT] = [TFDT()]
    var trackRun: [TRUN] = [TRUN()]
    
    static func from(_ samples: [Sample], previousDuration: UInt64) -> [TRAF] {
        
        var traf = TRAF()
        if let sample = samples.first {
            traf.trackFragmentHeader = [TFHD.from(sample: sample)]
            
            let duration = samples.reduce(0) { (cnt, sample) in cnt + sample.duration.value }
            traf.trackDecodeAtom = [TFDT.from(decode: UInt64(sample.decode.value),
                                              duration: UInt64(duration) )]
        }
        
        traf.trackRun = [TRUN.from(samples: samples)]
        
        return [traf]
    }
    
}
