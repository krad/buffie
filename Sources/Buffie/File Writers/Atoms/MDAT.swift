// Media Data Atom
struct MDAT: BinaryEncodable {
    
    let type: Atom = .mdat
    
    var sampleData: [UInt8]
    
}
