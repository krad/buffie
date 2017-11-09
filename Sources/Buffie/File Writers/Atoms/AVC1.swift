// FIXME
struct AVC1: BinarySizedEncodable {
    
    let type: Atom = .avc1

    var avcC: [AVCC] = [AVCC()]
    var colr: [COLR] = [COLR()]
    var pasp: [PASP] = [PASP()]
}

