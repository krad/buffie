import Foundation
import Buffie

public func determineContainer(from fileName: String) -> MovieFileContainer? {
    let components = fileName.components(separatedBy: ".")
    if let ext = components.last {
        return MovieFileContainer(rawValue: ext)
    }
    
    return nil
}
