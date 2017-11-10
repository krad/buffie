struct TRUN: BinarySizedEncodable {
    
    let type: Atom          = .trun
    let trFlags: SampleFlags = [.dataOffsetPresent,
                                .sampleDurationPresent,
                                .sampleSizePresent,
                                .sampleFlagsPresent,
                                .sampleCompositionTimeOffsetsPresent]
    
    var sampleCount: UInt32 = 0
    var dataOffset: Int32   = 1052
    
    var samples: [TRUNSample] = []
    
    static func from(samples: [Sample]) -> TRUN {
        var trun     = TRUN()
        trun.samples = samples.map { TRUNSample(duration: UInt32($0.duration.value),
                                                size: $0.size,
                                                flags: [SampleFlags(rawValue: 0)],
                                                compositionTimeOffset: UInt32(($0.pts.value / Int64($0.duration.timescale)) / 90)) }
        trun.sampleCount = UInt32(trun.samples.count)
        return trun
    }
    
}

struct TRUNSample: BinaryEncodable {
    
    var duration: UInt32              = 0
    var size: UInt32                  = 0
    var flags: SampleFlags            = SampleFlags(rawValue: 0)
    var compositionTimeOffset: UInt32 = 0
    
}

struct SampleFlags: BinaryEncodable, OptionSet {
    var rawValue: UInt32
    static let dataOffsetPresent                   = SampleFlags(rawValue: 0x000001)
    static let firstSampleFlagsPresent             = SampleFlags(rawValue: 0x000004)
    static let sampleDurationPresent               = SampleFlags(rawValue: 0x000100)
    static let sampleSizePresent                   = SampleFlags(rawValue: 0x000200)
    static let sampleFlagsPresent                  = SampleFlags(rawValue: 0x000400)
    static let sampleCompositionTimeOffsetsPresent = SampleFlags(rawValue: 0x000800)
    
}
