import Foundation

public struct NALUStreamIterator: Sequence, IteratorProtocol {
    
    let streamBytes: [UInt8]
    var currentIdx: Int = 0
    
    mutating public func next() -> NALU? {
        guard self.currentIdx < streamBytes.count else { return nil }
        
        if let naluSize = UInt32(bytes: Array(streamBytes[currentIdx..<currentIdx+4])) {
            let nextIdx = currentIdx + Int(naluSize) + 4
            
            let naluData = Array(streamBytes[currentIdx..<nextIdx])
            let nalu     = NALU(data: naluData)
            
            self.currentIdx += nextIdx
            return nalu
        }
        
        return nil
    }
    
}

func fourCharCode(from str: String) -> FourCharCode {
    var string = str
    if string.unicodeScalars.count < 4 {
        string = str + "    "
    }
    
    //string = string.substringToIndex(string.startIndex.advancedBy(4))
    
    var res:FourCharCode = 0
    for unicodeScalar in string.unicodeScalars {
        res = (res << 8) + (FourCharCode(unicodeScalar) & 255)
    }
    
    return res
}
