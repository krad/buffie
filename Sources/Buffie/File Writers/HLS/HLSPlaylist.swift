import Foundation
import CoreMedia

enum HLSPlaylistType: String {
    case vod   = "VOD"
    case live  = "LIVE"
    case event = "EVENT"

    internal func header(with targetDuration: Float64) -> String {
        return self.headerLines(with: Int64(targetDuration)).joined(separator: "\n")
    }

    private func headerLines(with targetDuration: Int64) -> [String] {
        switch self {
        case .vod:
            return self.vodLines(with: targetDuration)
        case .live:
            return self.liveLines(with: targetDuration)
        case .event:
            return self.eventLines(with: targetDuration)
        }
    }
    
    private func vodLines(with targetDuration: Int64) -> [String] {
        return [
            "#EXTM3U",
            "#EXT-X-TARGETDURATION:\(targetDuration)",
            "#EXT-X-VERSION:7",
            "#EXT-X-MEDIA_SEQUENCE:1",
            "#EXT-X-PLAYLIST-TYPE:\(self.rawValue)",
            "#EXT-X-INDEPENDENT-SEGMENTS",
            "#EXT-X-MAP:URI=\"fileSeq0.mp4\"\n"
        ]
    }
    
    private func liveLines(with targetDuration: Int64) -> [String] {
        return [
            "#EXTM3U",
            "#EXT-X-TARGETDURATION:\(targetDuration)",
            "#EXT-X-VERSION:7\n"
        ]
    }
    
    private func eventLines(with targetDuration: Int64) -> [String] {
        return [
            "#EXTM3U",
            "#EXT-X-PLAYLIST-TYPE:\(self.rawValue)\n",
        ]
    }
}

class HLSPlaylistWriter {
    
    var file: URL
    var fileHandle: FileHandle
    var playlistType: HLSPlaylistType
    
    init(_ file: URL, playlistType: HLSPlaylistType = .vod) throws {
        self.file         = file
        self.playlistType = playlistType
        
        if !FileManager.default.fileExists(atPath: file.path) {
            FileManager.default.createFile(atPath: file.path, contents: nil, attributes: nil)
        }
        
        self.fileHandle    = try FileHandle(forWritingTo: file)
    }
    
    func writerHeader(with targetDuration: Float64) {
        self.write(self.playlistType.header(with: targetDuration))
    }
    
    func write(segment: FragmentedMP4Segment) {
        if let name = segment.file.path.components(separatedBy: "/").last {
            self.writeSegment(named: name, with: Double(segment.duration))
        }
    }
    
    func writeSegment(named fileName: String, with length: Float64) {
        let payloadString = [
            "#EXTINF:\(length),",
            "\(fileName)",
            "#EXT-X-ENDLIST\n"
        ].joined(separator: "\n")
        
        self.write(payloadString)
    }
    
    private func write(_ string: String) {
        let payloadBytes: [UInt8] = Array(string.utf8)
        let data                  = Data(payloadBytes)
        self.fileHandle.write(data)
    }
    
}
