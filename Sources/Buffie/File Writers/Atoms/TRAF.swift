struct TRAF: BinarySizedEncodable {
    
    let type: Atom = .traf
    
    var trackFragmentHeader: [TFHD] = [TFHD()]
    var trackRun: [TRUN] = [TRUN()]
    
    static func from(_ samples: [Sample]) -> [TRAF] {
        
        var traf = TRAF()
        traf.trackFragmentHeader = [TFHD.from(sample: samples.first!)]
        traf.trackRun = [TRUN.from(samples: samples)]
        return [traf]

//        var result: [TRAF] = []
//        var runs: [TRUN] = []
//        for chunk in samples.chunks(15) {
//            let trun = TRUN.from(samples: chunk)
//            runs.append(trun)
//        }
//        traf.trackRun = runs
//        result.append(traf)
        
//        return result
    }
    
}

extension Array {
    func chunks(_ chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
}
