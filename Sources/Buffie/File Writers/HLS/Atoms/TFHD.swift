// Track Fragment Header
struct TFHD: BinarySizedEncodable {
    
    let type: Atom = .tfhd
    var tfFlags: TrackFragmentFlags = [.defaultBaseIsMOOF,
                                       .defaultSampleDurationPresent,
                                       .sampleDescriptionIndexPresent,
                                       .defaultSampleSizePresent,
                                       .defaultSampleFlagsPresent]
    
    var trackID: UInt32                = 1
    var sampleDescriptionIndexPresent: UInt32 = 1
    var defaultSampleDuration: UInt32  = 0
    var defaultSampleSize: UInt32      = 0
    var defaultSampleFlags: TrackFragmentFlags = TrackFragmentFlags(rawValue: 0x2000000)
    
    static func from(sample: VideoSample) -> TFHD {
        var tfhd                   = TFHD()
        tfhd.trackID               = 1
        tfhd.defaultSampleDuration = UInt32(sample.duration.value)
        tfhd.defaultSampleSize     = sample.size
        return tfhd
    }
    
    static func from(sample: AudioSample) -> TFHD {
        var tfhd               = TFHD()
        tfhd.trackID           = 2
//        tfhd.tfFlags           = [.defaultBaseIsMOOF,
//                                  .defaultSampleDurationPresent,
//                                  .defaultSampleSizePresent]
//
//        tfhd.defaultSampleSize     = sample.size
//        tfhd.defaultSampleDuration = 1024

        return tfhd
    }
    
}

struct TrackFragmentFlags: BinaryEncodable, OptionSet {
    var rawValue: UInt32
    static let defaultBaseIsMOOF                = TrackFragmentFlags(rawValue: 0x20000)
    static let baseDataOffsetPresent            = TrackFragmentFlags(rawValue: 0x000001)
    static let sampleDescriptionIndexPresent    = TrackFragmentFlags(rawValue: 0x000002)
    static let defaultSampleDurationPresent     = TrackFragmentFlags(rawValue: 0x000008)
    static let defaultSampleSizePresent         = TrackFragmentFlags(rawValue: 0x000010)
    static let defaultSampleFlagsPresent        = TrackFragmentFlags(rawValue: 0x000020)
    static let durationIsEmpty                  = TrackFragmentFlags(rawValue: 0x010000)

}
