// Media Data Atom
struct MDAT: BinaryEncodable {
    
    let type: Atom = .mdat
    private var data: [UInt8] = []
    
    init(samples: [VideoSample]) {
        for sample in samples {
            for nalu in sample.nalus {
                data.append(contentsOf: nalu.data)
            }
        }
    }
    
}
