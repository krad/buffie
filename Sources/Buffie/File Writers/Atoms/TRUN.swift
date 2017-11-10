struct TRUN: BinarySizedEncodable {
    
    let type: Atom          = .trun
    var version: UInt8      = 0
    var flags: [UInt8]      = [0, 0, 0]
    var offset: UInt32      = 0
    var sampleCount: UInt32 = 0
    
    var samples: [TRUNSample] = []
    
    var totalDuration: UInt64 = 0
}

struct TRUNSample: BinaryEncodable {
    
    var duration: UInt64              = 0
    var size: UInt32                  = 0
    var flags: [UInt8]                = [0]
    var compositionTimeOffset: UInt32 = 0
    
}
