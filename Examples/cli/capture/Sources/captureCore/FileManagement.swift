import Foundation

public enum Container: String {
    case mp4 = "mp4"
    case m4v = "m4v"
    case mov = "mov"
}

public enum Quality: String {
    case low    = "low"
    case medium = "medium"
    case high   = "high"
}

public func determineContainer(from fileName: String) -> Container? {
    let components = fileName.components(separatedBy: ".")
    if let ext = components.last {
        return Container(rawValue: ext)
    }
    
    return nil
}
