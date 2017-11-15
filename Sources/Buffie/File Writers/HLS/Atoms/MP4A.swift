struct MP4A: BinarySizedEncodable {
    
    let type: Atom         = .mp4a
    var reservedA: UInt64   = 0
    var reservedB: UInt64   = 0

    var channels: UInt16   = 2
    var sampleSize: UInt16 = 16
    var reservedC: UInt32  = 0
    var sampleRate: UInt32 = 44100 << 16
    
    var esds: [ESDS]       = [ESDS()]
    
    static func from(_ config: MOOVAudioSettings) -> MP4A {
        var mp4a        = MP4A()
        mp4a.channels   = UInt16(config.channels)
        mp4a.sampleSize = config.bitDepth
        mp4a.sampleRate = config.sampleRate << 16
        mp4a.esds       = [ESDS()]
        return mp4a
    }
    
}
