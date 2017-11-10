// Track Fragment Header
struct TFHD: BinarySizedEncodable {
    
    let type: Atom = .tfhd
//    var version: UInt8 = 0
    var tfFlags: TrackFragmentFlags = [.defaultSampleDurationPresent,
                                       .defaultSampleSizePresent,
                                       .defaultSampleFlagsPresent]
    
    var trackID: UInt32                = 1
//    var baseDataOffset: UInt64         = 0
//    var sampleDescriptionIndex: UInt32 = 0
    var defaultSampleDuration: UInt32  = 0
    var defaultSampleSize: UInt32      = 0
    var defaultSampleFlags: UInt32     = 0
    
    static func from(sample: Sample) -> TFHD {
        var tfhd                   = TFHD()
        tfhd.trackID               = sample.type == .video ? UInt32(1) : UInt32(2)
        tfhd.defaultSampleDuration = UInt32(sample.duration.value)
        tfhd.defaultSampleSize     = sample.size
        return tfhd
    }
    
}

struct TrackFragmentFlags: BinaryEncodable, OptionSet {
    var rawValue: UInt32
    static let baseDataOffsetPresent            = TrackFragmentFlags(rawValue: 0x000001)
    static let sampleDescriptionIndexPresent    = TrackFragmentFlags(rawValue: 0x000002)
    static let defaultSampleDurationPresent     = TrackFragmentFlags(rawValue: 0x000008)
    static let defaultSampleSizePresent         = TrackFragmentFlags(rawValue: 0x000010)
    static let defaultSampleFlagsPresent        = TrackFragmentFlags(rawValue: 0x000020)
    static let durationIsEmpty                  = TrackFragmentFlags(rawValue: 0x010000)

}
