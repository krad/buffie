import Buffie
import Foundation
import captureCore

do {

    let tool = try CommandLineTool()
    try tool.run()
    
} catch CommandLineToolError.noOptions {
    
    printUsage()
    
} catch {
    
    exit(-1)
    
}
