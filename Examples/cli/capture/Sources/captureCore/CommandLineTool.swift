import Foundation
import Buffie

public enum CommandLineToolError: Error {
    case noOptions
    case noFile
    case listInputs(options: HelpOptions)
    case fileExists
}

public struct HelpOptions: OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let printVideoInputs = HelpOptions(rawValue: 1 << 0)
    public static let printAudioInputs = HelpOptions(rawValue: 1 << 1)
}


public class CommandLineTool {
    
    public var url: URL?
    
    public var container: MovieFileContainer = .mp4
    public var time: Int?
    public var quality: MovieFileQuality = .high
    public var forceOverwrite = false
    public var bitrate: Int?
    public var videoDeviceID: String?
    public var audioDeviceID: String?
    
    private var signalTrap: SignalTrap?

    internal var helpOptions: HelpOptions = []
    
    public init(_ arguments: [String] = CommandLine.arguments) throws {
        guard arguments.count > 1 else { throw CommandLineToolError.noOptions }
        self.parseOptions(arguments: arguments)
    }
    
    public func run() throws {
        guard self.helpOptions.isEmpty else {
            throw CommandLineToolError.listInputs(options: self.helpOptions)
        }
        
        guard let url = self.url else { throw CommandLineToolError.noFile }

        if FileManager.default.fileExists(atPath: url.path) {
            if self.forceOverwrite {
                try FileManager.default.removeItem(atPath: url.path)
            } else {
                throw CommandLineToolError.fileExists
            }
        }
        
        // This is the meat and potatoes.
        // This is how we use Buffie.  Look at the source of CameraOutputReader
        let cameraReader = CameraOutputReader(url: url,
                                              container: self.container,
                                              bitrate: self.bitrate,
                                              quality: self.quality)
        var camera: Camera
        
        if let videoDeviceID = self.videoDeviceID, let audioDeviceID = self.audioDeviceID {
            camera = try Camera(videoDeviceID: videoDeviceID,
                                audioDeviceID: audioDeviceID,
                                reader: cameraReader,
                                controlDelegate: nil)
        } else {
            camera = try Camera(.back, reader: cameraReader, controlDelegate: nil)
        }
        
        /// This is what get's called when it's time to shutdown the program.
        let stopFunction = {
            print("Finishing up...")
            cameraReader.stop() { exit(0) }
            camera.stop()
        }
        
        // Trap sigint signals and trigger cleanup when they're spotted.
        self.signalTrap = SignalTrap(SIGINT, onTrap: stopFunction)
        
        // Start the camera & recorder.  Let the user know we're running.
        camera.start()
        printRunningMessage()
        
        // There was a timeout.  Schedule shutdown for timer
        if let timeout = self.time {
            let delayTime = DispatchTime.now() + .seconds(timeout)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                stopFunction()
            }
        }

        dispatchMain()
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
                if let container = determineContainer(from: file) {
                    self.container = container
                }
                
            case "c"?:
                if let container = MovieFileContainer(rawValue: String(cString: optarg)) {
                    self.container = container
                }
                
            case "l"?:
                self.helpOptions.insert(.printVideoInputs)
                
            case "w"?:
                self.helpOptions.insert(.printAudioInputs)
                
            case "v"?:
                self.videoDeviceID = String(cString: optarg)
                
            case "a"?:
                self.audioDeviceID = String(cString: optarg)
                
            case "q"?:
                if let quality = MovieFileQuality(rawValue: String(cString: optarg)) {
                    self.quality = quality
                }
                
            case "b"?:
                self.bitrate = (String(cString: optarg) as NSString).integerValue
                
            case "f"?:
                self.forceOverwrite = true
                
            default:
                break
            }
            
        } while (true)
        
        optind = 1 /// getopt is kinda hacky. Reset index so tests don't freak out
    }
    
}
