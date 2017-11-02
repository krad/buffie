import Foundation

public enum CommandLineToolError: Error {
    case noOptions
    case noFile
}

internal struct HelpOptions: OptionSet {
    let rawValue: Int
    
    static let printVideoInputs = HelpOptions(rawValue: 1 << 0)
    static let printAudioInputs = HelpOptions(rawValue: 1 << 1)
}

public class CommandLineTool {
    
    public var url: URL?
    public var container: Container?
    public var time: Int?
    public var quality: Quality? = .high
    public var forceOverwrite = false
    public var bitrate: Int32?
    public var videoDeviceID: String?
    public var audioDeviceID: String?

    internal var helpOptions: HelpOptions = []
    
    public init(_ arguments: [String] = CommandLine.arguments) throws {
        guard arguments.count > 1 else { throw CommandLineToolError.noOptions }
        self.parseOptions(arguments: arguments)
    }
    
    public func run() throws {
        
    }
    
    private func parseOptions(arguments: [String]) {
        var cargs = arguments.map { strdup($0) }
        repeat {
            let ch = getopt(Int32(arguments.count), &cargs, "lwv:a:o:t:c:q:b:f")
            if ch  == -1 { break }
            
            switch UnicodeScalar(Int(ch)).flatMap(Character.init) {
            case "t"?:
                self.time = (String(cString: optarg) as NSString).integerValue
                
            case "o"?:
                let file        = String(cString: optarg)
                self.url        = URL(fileURLWithPath: file)
                self.container  = determineContainer(from: file)
                
            case "c"?:
                self.container = Container(rawValue: String(cString: optarg))
                
            case "l"?:
                self.helpOptions.insert(.printVideoInputs)
                
            case "w"?:
                self.helpOptions.insert(.printAudioInputs)
                
            case "v"?:
                self.videoDeviceID = String(cString: optarg)
                
            case "a"?:
                self.audioDeviceID = String(cString: optarg)
                
            case "q"?:
                self.quality = Quality(rawValue: String(cString: optarg))
                
            case "b"?:
                self.bitrate = (String(cString: optarg) as NSString).intValue
                
            case "f"?:
                self.forceOverwrite = true
                
            default:
                break
            }
            
        } while (true)
        
        optind = 1 /// getopt is kinda hacky. Reset index so tests don't freak out
    }
    
}

//var done = false
//
//do {
//    let cameraReader = CameraOutputReader()
//    let camera       = try Camera(.back, reader: cameraReader, controlDelegate: nil)
//    camera.start()
//} catch {
//    print("Couldn't access camera")
//}
//
//while !done {
//    dispatchMain()
//}

