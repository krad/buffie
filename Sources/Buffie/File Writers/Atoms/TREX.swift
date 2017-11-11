struct TREX: BinarySizedEncodable {
    
    let type: Atom = .trex
    
    var version: UInt8 = 0
    var flags: [UInt8] = [0, 0, 0]
    
    var trackID: UInt32 = 2
    var sampleDescriptionIndex: UInt32 = 1
    var sampleDuration: UInt32 = 0
    var sampleSize: UInt32 = 0
    
    // I used to not know what this is.
    // These are the default values for movie fragments
    // Look at the SampleFlags struct/OptionSet for a definition
    // TODO: Change this to a SampleFlags struct
    var sampleFlags: UInt32 = 0x1010000

}
