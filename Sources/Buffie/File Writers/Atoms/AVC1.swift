// FIXME
struct AVC1: BinarySizedEncodable {
    
    let type: Atom = .avc1
    
    var reserved: [UInt8] = [0, 0, 0, 0, 0 ,0]
    
    var dataReferenceIndex: UInt16 = 1
    var version: UInt16 = 0
    var revisionLevel: UInt16 = 0
    var vendor: UInt32 = 0
    var temporalQuality: UInt32 = 0
    var spatialQuality: UInt32 = 0
    
    var width: UInt16 = 1280
    var height: UInt16 = 720
    var horizontalResolution: UInt32 = 4718592
    var verticalResolution: UInt32 = 4718592
    
    var dataSize: UInt32 = 0
    var frameCount: UInt16 = 1
    var compressorNameSize: UInt8 = 0
    var padding: [UInt8] = [0, 0, 0, 0, 0, 0, 0, 0,
                            0, 0, 0, 0, 0, 0, 0, 0,
                            0, 0, 0, 0, 0, 0, 0, 0,
                            0, 0, 0, 0, 0, 0, 0]
    
    var depth: UInt16 = 24
    var colorTableID: UInt16 = 65535
    

    var avcC: [AVCC] = [AVCC()]
    var colr: [COLR] = [COLR()]
    var pasp: [PASP] = [PASP()]
}


//<item offset="433" name="Reserved">0</item>
//<item offset="439" name="Data reference index">1</item>
//<item offset="441" name="Version">0</item>
//<item offset="443" name="Revision level">0</item>
//<item offset="445" name="Vendor"></item>
//<item offset="449" name="Temporal quality">0</item>
//<item offset="453" name="Spatial quality">0</item>
//<item offset="457" name="Width">1280</item>
//<item offset="459" name="Height">720</item>
//<item offset="461" name="Horizontal resolution">4718592</item>
//<item offset="465" name="Vertical resolution">4718592</item>
//<item offset="469" name="Data size">0</item>
//<item offset="473" name="Frame count">1</item>
//<item offset="475" name="Compressor name size">0</item>
//<item offset="476" name="Padding">(31 bytes)</item>
//<item offset="507" name="Depth">24</item>
//<item offset="509" name="Color table ID">65535</item>

