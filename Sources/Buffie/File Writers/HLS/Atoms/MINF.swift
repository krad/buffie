struct MINF: BinarySizedEncodable {
    
    let type: Atom = .minf
    var videoMediaInformationAtom: [VMHD] = [VMHD()]
    var dataInformationAtom: [DINF] = [DINF()]
    var sampleTableAtom: [STBL] = [STBL()]
    
    static func from(_ config: MOOVVideoSettings) -> MINF {
        var minf = MINF()
        minf.sampleTableAtom = [STBL.from(config: config)]
        return minf
    }
    
}
