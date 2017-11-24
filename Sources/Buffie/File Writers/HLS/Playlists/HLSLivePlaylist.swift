import Foundation

class HLSLivePlayerWriter: PlaylistWriter {
    
    var segments: [(String, Float64)] = []
    private var header: String = ""
    private var numberOfSegments: Int
    
    init(numberOfSegments: Int = 6) {
        self.numberOfSegments = numberOfSegments
    }
    
    func positionToSeek() -> UInt64? {
        return UInt64(self.header.count)
    }
    
    func header(with targetDuration: Int64) -> String {
        self.header = [
            "#EXTM3U",
            "#EXT-X-TARGETDURATION:\(targetDuration)",
            "#EXT-X-VERSION:7",
            "#EXT-X-MEDIA-SEQUENCE:0",
            "#EXT-X-PLAYLIST-TYPE:VOD",
            "#EXT-X-INDEPENDENT-SEGMENTS",
            "#EXT-X-MAP:URI=\"fileSeq0.mp4\"\n"
        ].joined(separator: "\n")
        return self.header
    }
    
    func writeSegment(with filename: String, and duration: Float64) -> String {
        
        if segments.count == self.numberOfSegments {
            self.segments.removeFirst(1)
        }
        
        self.segments.append((filename, duration))
        return self.segments.map { entry in
            segmentEntry(fileName: entry.0, duration: entry.1)
        }.joined(separator: "\n") + "\n"
    }
    
    func end() -> String {
        return ""
    }
    
}

func segmentEntry(fileName: String, duration: Double) -> String {
    return "#EXTINF:\(duration),\n\(fileName)"
}
