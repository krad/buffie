import Foundation

protocol PlaylistWriter {
    var currentMediaSequence: Int { get set }
    func positionToSeek() -> UInt64?
    func header(with targetDuration: Int64) -> String
    func writeSegment(with filename: String, and duration: Float64) -> String
    func end() -> String
}

public enum HLSPlaylistType: String {
    case vod   = "VOD"
    case live  = "LIVE"
    case event = "EVENT"
}
