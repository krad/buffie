import Foundation
import captureCore
import AVFoundation

do {
    
    let tool = try CommandLineTool()
    try tool.run()
    
} catch CommandLineToolError.noOptions {
    
    printUsage()
    
} catch CommandLineToolError.listInputs(let options) {
    
    print("")
    if options.contains(.printVideoInputs) {
        printVideoDevices()
    }
    
    if options.contains(.printAudioInputs) {
        printAudioDevices()
    }
    
} catch CommandLineToolError.fileExists {
    
    print("Output file already exists.  Use -f flag to force overwrite.")
    
} catch {
    
    print("Error running capture.  Run command with no options for detailed help.")
    exit(-1)
    
}
