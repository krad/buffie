import Foundation

public struct NALU: CustomStringConvertible {
    
    var data: [UInt8]

    var type: NALUType {
        return NALUType(rawValue: self.data[4] & 0x1f)!
    }
    
    var size: UInt32 {
        return UInt32(bytes: Array(self.data[0..<4]))!
    }

    
    init(data: [UInt8]) {
        self.data = data
    }
    
    public var description: String {
        return "NALU(type: \(self.type), size: \(self.size))"
    }
    
}

public enum NALUType: UInt8, CustomStringConvertible {
    case Undefined           = 0
    case CodedSlice          = 1
    case DataPartitionA      = 2
    case DataPartitionB      = 3
    case DataPartitionC      = 4
    case IDR                 = 5
    case SEI                 = 6
    case SPS                 = 7
    case PPS                 = 8
    case AccessUnitDelimiter = 9
    case EndOfSequence       = 10
    case EndOfStream         = 11
    case FilterData          = 12
    
    public var description : String {
        switch self {
        case .CodedSlice:           return "CodedSlice"
        case .DataPartitionA:       return "DataPartitionA"
        case .DataPartitionB:       return "DataPartitionB"
        case .DataPartitionC:       return "DataPartitionC"
        case .IDR:                  return "IDR"
        case .SEI:                  return "SEI"
        case .SPS:                  return "SPS"
        case .PPS:                  return "PPS"
        case .AccessUnitDelimiter:  return "AccessUnitDelimiter"
        case .EndOfSequence:        return "EndOfSequence"
        case .EndOfStream:          return "EndOfStream"
        case .FilterData:           return "FilterData"
        default:                    return "Undefined"
        }
    }
}
