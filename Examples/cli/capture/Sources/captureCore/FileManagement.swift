import Foundation

public func determineContainer(from fileName: String) -> Container? {
    let components = fileName.components(separatedBy: ".")
    if let ext = components.last {
        return Container(rawValue: ext)
    }
    
    return nil
}
