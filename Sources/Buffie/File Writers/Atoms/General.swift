import Foundation

enum Atom: String, BinaryEncodable {
    case ftyp = "ftyp"
    case mvhd = "mvhd"
    case tkhd = "tkhd"
    case mdhd = "mdhd"
    case hdlr = "hdlr"
    case vmhd = "vmhd"
    case dref = "dref"
    case dinf = "dinf"
    case stco = "stco"
    case stsz = "stsz"
    case stsc = "stsc"
    case stts = "stts"
    case pasp = "pasp"
}

enum Brand: String, BinaryEncodable {
    case mp41 = "mp41"
    case mp42 = "mp42"
    case isom = "isom"
    case hlsf = "hlsf"
}

enum AtomDataType: String, BinaryEncodable {
    case video      = "vide"
    case sound      = "soun"
    case subtitles  = "subt"
    case alias      = "alis"
}

