import Foundation

public protocol AsyncEncoder {
    associatedtype T
    func encoded(_ data: T)
}

public protocol AsyncDecoder {
    associatedtype T
    func decoded(_ data: T)
}
