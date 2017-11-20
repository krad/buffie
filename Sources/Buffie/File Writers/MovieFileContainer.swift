import Foundation
import AVFoundation

public enum MovieFileContainer: String {
    case mp4 = "mp4"
    case m4v = "m4v"
    case mov = "mov"
    
    internal var fileType: AVFileType {
        switch self {
        case .mp4: return AVFileType.mp4
        case .m4v: return AVFileType.m4v
        case .mov: return AVFileType.mov
        }
    }
}
