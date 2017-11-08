import Foundation

struct TKHD: BinaryEncodable {
    
    let type: Atom = .tkhd
    var version: UInt8 = 0
    var flags: [UInt8] = [0, 0, 1]
    
    var creationTime: UInt32     = 3592932068
    var modificationTime: UInt32 = 3592932068

    var trackID: UInt32     = 1
    var reservedA: UInt32   = 0
    var duration: UInt32    = 0
    var reservedB: UInt64   = 0
    
    var layer: UInt16 = 0
    var alternateGroup: UInt16 = 0
    
    var volume: UInt16 = 0x0100
    var reservedC: UInt16 = 0
    
    var matrixStructure: [UInt8] = [0, 1, 0, 0, 0, 0, 0, 0,
                                    0, 0, 0, 0, 0, 0, 0, 0,
                                    0, 1, 0, 0, 0, 0, 0, 0,
                                    0, 0, 0, 0, 0, 0, 0, 0,
                                    64, 0, 0, 0]

    var trackWidth: UInt32  = 1280 << 16
    var trackHeight: UInt32 = 720 << 16
    
}
