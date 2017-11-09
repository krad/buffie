// FIXME
struct AVC1: BinaryEncodable {
    
    let type: Atom = .avc1

    var trackWidth: UInt32  = 1280 << 16
    var trackHeight: UInt32 = 720 << 16

    var avcC = AVCC()
    var colr = COLR()
    var pasp = PASP()
}

