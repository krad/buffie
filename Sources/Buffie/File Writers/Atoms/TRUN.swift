struct TRUN: BinarySizedEncodable {
    
    let type: Atom          = .trun
    let trFlags: TRUNFlags  = [.dataOffsetPresent,
                               .sampleDurationPresent,
                               .sampleSizePresent,
                               .sampleFlagsPresent]
    
    var sampleCount: UInt32 = 0
    var dataOffset: Int32   = 0
    
    var samples: [TRUNSample] = []
    
    static func from(samples: [Sample]) -> TRUN {
        var trun     = TRUN()
        trun.samples = samples.map { TRUNSample($0) }
        trun.sampleCount = UInt32(trun.samples.count)
        return trun
    }
    
}

struct TRUNFlags: BinaryEncodable, OptionSet {
    var rawValue: UInt32
    static let dataOffsetPresent                   = TRUNFlags(rawValue: 0x000001)
    static let firstSampleFlagsPresent             = TRUNFlags(rawValue: 0x000004)
    static let sampleDurationPresent               = TRUNFlags(rawValue: 0x000100)
    static let sampleSizePresent                   = TRUNFlags(rawValue: 0x000200)
    static let sampleFlagsPresent                  = TRUNFlags(rawValue: 0x000400)
    static let sampleCompositionTimeOffsetsPresent = TRUNFlags(rawValue: 0x000800)
}

struct TRUNSample: BinaryEncodable {
    var duration: UInt32              = 0
    var size: UInt32                  = 0
    var flags: SampleFlags            = []
//    var compositionTimeOffset: UInt32 = 0
    
    init(_ sample: Sample) {
        self.duration              =  UInt32(sample.duration.value)
        self.size                  =  sample.size
//        self.compositionTimeOffset = UInt32((sample.pts.value / Int64(sample.duration.timescale)) / 90)
        
        if sample.isSync          { self.flags.insert(.sampleIsDependedOn) }
        if sample.dependsOnOthers { self.flags.insert(.sampleDependsOn) }
        
    }
}

// bit(6) reserved = 0
// unsigned int(2) samples_depends_on
// unsigned int(2) sample_is_depended_on
// unsigned int(2) sample_has_redundancy
// bit(3) sample_padding_value
// bit(1) sample_is_difference_sample
struct SampleFlags: BinaryEncodable, OptionSet {
    var rawValue: UInt32
    static let reserved           = SampleFlags(rawValue: 0b00000000000000000000000000000000)
    static let sampleDependsOn    = SampleFlags(rawValue: 0b00000011000000000000000000000000)
    static let sampleIsDependedOn = SampleFlags(rawValue: 0b00000000110000000000000000000000)
}

