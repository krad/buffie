import Foundation

struct DINF: BinaryEncodable {
    
    var type: Atom = .dinf
    var dref = [DREF()]
        
}
