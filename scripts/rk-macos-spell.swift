#!/usr/bin/env swift
import AppKit
import Foundation

let arguments = CommandLine.arguments
guard arguments.count == 2 else {
    FileHandle.standardError.write(Data("usage: rk-macos-spell.swift <language>\n".utf8))
    exit(64)
}

let language = arguments[1]
let data = FileHandle.standardInput.readDataToEndOfFile()
guard let text = String(data: data, encoding: .utf8) else {
    FileHandle.standardError.write(Data("stdin must be UTF-8\n".utf8))
    exit(65)
}

let checker = NSSpellChecker.shared
let nsText = text as NSString
var start = 0

func lineAndColumn(for index: String.Index, in text: String) -> (Int, Int) {
    var line = 1
    var column = 0
    var current = text.startIndex

    while current < index {
        if text[current] == "\n" {
            line += 1
            column = 0
        } else {
            column += 1
        }
        current = text.index(after: current)
    }

    return (line, column)
}

while start < nsText.length {
    let range = checker.checkSpelling(
        of: text,
        startingAt: start,
        language: language,
        wrap: false,
        inSpellDocumentWithTag: 0,
        wordCount: nil
    )

    if range.location == NSNotFound || range.length == 0 {
        break
    }

    if let stringRange = Range(range, in: text) {
        let (line, column) = lineAndColumn(for: stringRange.lowerBound, in: text)
        let word = String(text[stringRange])
            .replacingOccurrences(of: "\t", with: " ")
            .replacingOccurrences(of: "\n", with: " ")
        let length = text.distance(from: stringRange.lowerBound, to: stringRange.upperBound)
        print("\(line)\t\(column)\t\(length)\t\(word)")
    }

    start = range.location + max(range.length, 1)
}
