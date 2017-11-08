import Foundation


struct DREF: BinaryEncodable {
    
    let type: Atom = .dref
    var version: UInt8 = 0
    var flags: [UInt8] = [0, 0, 0]
    var numberOfEntries: UInt32 = 1
    
    var references: [DREFReference] = [DREFReference()]
    
}

struct DREFReference: BinaryEncodable {
    
    var type: DREFType = .url
    var version: UInt8 = 0
    var flags: [UInt8] = [0, 0, 1]
    
    enum CodingKeys: String, CodingKey {
        case size
        case type
        case version
        case flags
    }
    
    func encode(to encoder: Encoder) throws {
        let newEncoder = BinaryEncoder()
        var newContainer = newEncoder.container(keyedBy: DREFReference.CodingKeys.self)
        try newContainer.encode(self.type, forKey: .type)
        try newContainer.encode(self.version, forKey: .version)
        try newContainer.encode(self.flags, forKey: .flags)
        
        var container = encoder.container(keyedBy: DREFReference.CodingKeys.self)
        try container.encode(UInt32(newEncoder.data.count + 4), forKey: .size)
        try container.encode(self.type, forKey: .type)
        try container.encode(self.version, forKey: .version)
        try container.encode(self.flags, forKey: .flags)
    }
    
}

enum DREFType: String, BinaryEncodable {
    case alis = "alis"
    case rsrc = "rsrc"
    case url  = "url "
}
