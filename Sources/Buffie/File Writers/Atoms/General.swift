import Foundation

enum Atom: String, BinaryEncodable {
    case ftyp = "ftyp"
    case mvhd = "mvhd"
    case tkhd = "tkhd"
    case mdhd = "mdhd"
//    case moov = "moov"
//    case moof = "moof"
//    case trak = "trak"
//    case traf = "traf"
//    case tfad = "tfad"
//    case mvex = "mvex"
//    case mdia = "mdia"
//    case minf = "minf"
//    case dinf = "dinf"
//    case stbl = "stbl"
//    case stsd = "stsd"
//    case sinf = "sinf"
//    case mfra = "mfra"
//    case udta = "udta"
//    case meta = "meta"
//    case schi = "schi"
//    case avc1 = "avc1"
//    case acv3 = "acv3"
//    case hvc1 = "hvc1"
//    case hev1 = "hev1"
//    case mp4a = "mp4a"
//    case encv = "encv"
//    case enca = "enva"
//    case skip = "skip"
//    case edts = "edts"
//
}

enum Brand: String, BinaryEncodable {
    case mp41 = "mp41"
    case mp42 = "mp42"
    case isom = "isom"
    case hlsf = "hlsf"
}
