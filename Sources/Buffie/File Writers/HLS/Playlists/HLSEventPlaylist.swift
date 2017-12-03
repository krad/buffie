import Foundation

class HLSEventPlaylist: PlaylistWriter {
    
    var currentMediaSequence: Int = 0
    
    func positionToSeek() -> UInt64? {
        return nil
    }
    
    func header(with targetDuration: Int64) -> String {
        return [
            "#EXTM3U",
            "#EXT-X-TARGETDURATION:\(targetDuration)",
            "#EXT-X-VERSION:7",
            "#EXT-X-MEDIA-SEQUENCE:\(self.currentMediaSequence)",
            "#EXT-X-PLAYLIST-TYPE:EVENT",
            "#EXT-X-INDEPENDENT-SEGMENTS",
            "#EXT-X-MAP:URI=\"fileSeq0.mp4\"\n"
        ].joined(separator: "\n")
    }
    
    func writeSegment(with filename: String, and duration: Float64) -> String {
        return segmentEntry(fileName: filename, duration: duration)
    }
    
    func end() -> String {
        return "#EXT-X-ENDLIST\n"
    }
    
    
}
