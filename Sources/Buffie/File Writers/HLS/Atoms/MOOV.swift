import CoreMedia

struct MOOV: BinaryEncodable {
    
    let type: Atom = .moov
    
    var movieHeaderAtom: [MVHD] = [MVHD()]
    var tracks: [TRAK] = [TRAK()]
    
    var mediaFragmentInfo: [MVEX] = [MVEX()]
    
    init(_ config: MOOVConfig) {
        self.movieHeaderAtom = [MVHD.from(config)]
        self.tracks = [TRAK.from(config)]
        
    }
        
}
