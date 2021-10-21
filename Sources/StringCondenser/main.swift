/*===============================================================================================================================================================================*
 *     PROJECT: StringCondenser
 *    FILENAME: main.swift
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 10/20/21
 *
 * Copyright © 2021 Galen Rhodes. All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this
 * permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO
 * EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN
 * AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *===============================================================================================================================================================================*/

import Foundation
import CoreFoundation
import Rubicon
import ArgumentParser
import SourceKittenFramework

struct StringCondenser: ParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Condense string literals into global variables.")

    @Option(name: [ .long, .customShort("d") ], help: "The directory to search for source files.") /*        */ var sourceDirectory:    String
    @Option(name: [ .long, .customShort("a") ], help: "The filename of the backup TAR file.") /*             */ var archiveFile:        String = "SourceBackup.tar.bz2"
    @Option(name: [ .long, .customShort("m") ], help: "The name of the source file with the global variables.") var messagesSourceFile: String = "Messages.swift"

    mutating func run() throws {
        let _msgSrcFile = "\(sourceDirectory)/\(messagesSourceFile)"
        print("    Source Directory: \(sourceDirectory)")
        print("    Archive Filename: \(archiveFile)")
        print("Messages Source File: \(_msgSrcFile)")

        let files: [String] = try FileManager.default.directoryFiles(atPath: sourceDirectory) { path, file, attrs in
            let fn = "\(path)/\(file)"
            guard fn != _msgSrcFile else { return false }
            guard fn.hasSuffix(".swift") else { return false }
            return true
        }

        print()
        // for f in files { print(f) }
        let results = try decodeFile(_msgSrcFile: _msgSrcFile)

        for f in files {
            let fileResults = try decodeFile(_msgSrcFile: f)
        }

//        let sd: SwiftDocs = SwiftDocs(file: file, arguments: [ "-scheme", "Z28", "-jobs", "8" ])!
//        print(sd.description)

//        guard let mod: Module = Module(xcodeBuildArguments: [ "-scheme", "Gettysburg" ], inPath: sourceDirectory.deletingLastPathComponent.deletingLastPathComponent) else {
//            throw StreamError.UnknownError()
//        }
//        print(mod.description)
//        let swiftDocs = mod.docs
//        print("Number of doc files: \(swiftDocs.count)")
    }

    private func decodeFile(_msgSrcFile: String) throws -> [String:SourceKitRepresentable] {
        guard let file = File(path: _msgSrcFile) else { throw StreamError.FileNotFound(description: _msgSrcFile) }
        let results = try Request.editorOpen(file: file).send()
        print(try decodedToJSON(results: results))
        return results
    }

    private func decodedToJSON(results: [String: SourceKitRepresentable]) throws -> String {
        for k in results.keys { print("Key: \(k)") }
        let nsResults = toNSDictionary(results)
        let data      = try JSONSerialization.data(withJSONObject: nsResults, options: [ .prettyPrinted, .sortedKeys ])
        return String(data: data, encoding: .utf8)!
    }
}

DispatchQueue.main.async { StringCondenser.main(); exit(0) }
dispatchMain()
