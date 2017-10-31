//
//  PathHelpers.swift
//  BuffieTests
//
//  Created by Mel Gray on 10/24/17.
//

import Foundation

let fixturesPath = findFixturePath()
let outputsPath  = findOutputPath()

private func testsDir() -> String {
    let pieces = #file.components(separatedBy: "/").dropLast()
    return pieces.joined(separator: "/")
}

private func appendToStringHack(path: String) -> String {
    var pieces = testsDir().components(separatedBy: "/")
    pieces.append(path)
    return pieces.joined(separator: "/")
}

private func findFixturePath() -> String {
    return appendToStringHack(path: "Fixtures")
}

private func findOutputPath() -> String {
    return appendToStringHack(path: "Outputs")
}


