import CoreMedia

struct TRAF: BinarySizedEncodable {
    
    let type: Atom = .traf
    
    var trackFragmentHeader: [TFHD] = [TFHD()]
    var trackDecodeAtom: [TFDT] = [TFDT()]
    var trackRun: [TRUN] = [TRUN()]
    
    static func from(_ samples: [Sample], previousDecodeTime: UInt64) -> [TRAF] {
        
        var traf = TRAF()
        if let sample = samples.first {
            traf.trackFragmentHeader = [TFHD.from(sample: sample)]
        }
        
        let duration = samples.reduce(kCMTimeZero) { (cnt, sample) in
            CMTimeAdd(cnt, sample.duration)
        }
        
        traf.trackDecodeAtom = [TFDT.from(decode: UInt64(samples.first!.decode.value),
                                          duration: UInt64(duration.value) + previousDecodeTime )]
        
        traf.trackRun = [TRUN.from(samples: samples)]
        return [traf]
    }
    
}
