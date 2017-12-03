import Foundation

class HLSVODPlaylist: PlaylistWriter {
    
    private var firstMediaSequence: Int = 0
    
    func positionToSeek() -> UInt64? {
        return nil
    }
    
    func header(with targetDuration: Int64) -> String {
        return [
            "#EXTM3U",
            "#EXT-X-TARGETDURATION:\(targetDuration)",
            "#EXT-X-VERSION:7",
            "#EXT-X-MEDIA_SEQUENCE:\(self.firstMediaSequence)",
            "#EXT-X-PLAYLIST-TYPE:LIVE",
            "#EXT-X-INDEPENDENT-SEGMENTS",
            "#EXT-X-MAP:URI=\"fileSeq0.mp4\"\n"
        ].joined(separator: "\n")
    }
    
    func writeSegment(with filename: String, duration: Float64, and firstMediaSequence: Int) -> String {
        self.firstMediaSequence = firstMediaSequence
        return segmentEntry(fileName: filename, duration: duration)
    }
    
    func end() -> String {
        return "#EXT-X-ENDLIST\n"
    }
    
}

