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
        var messageSource: SourceFile = try SourceFile(filename: "\(sourceDirectory)/\(messagesSourceFile)")
        var sourceFiles: [SourceFile] = try FileManager.default.directoryFiles(atPath: sourceDirectory, where: { path, file, attrs in
            let fn = "\(path)/\(file)"
            guard fn != messageSource.filename else { return false }
            guard fn.hasSuffix(".swift") else { return false }
            return true
        }).map { try SourceFile(filename: $0) }

        print("    Source Directory: \(sourceDirectory)")
        print("    Archive Filename: \(archiveFile)")
        print("Messages Source File: \(messageSource.filename)")
        print()
    }

    @inlinable func decodeFile(filename: String) throws -> [String: SourceKitRepresentable] {
        guard let file = File(path: filename) else { throw StreamError.FileNotFound(description: filename) }
        return try Request.editorOpen(file: file).send()
    }

    @inlinable func decodedToJSON(data: [String: SourceKitRepresentable]) throws -> String {
        String(data: try JSONSerialization.data(withJSONObject: toNSDictionary(data), options: [ .prettyPrinted, .sortedKeys ]), encoding: .utf8)!
    }
}

DispatchQueue.main.async {
    StringCondenser.main()
    exit(0)
}
dispatchMain()
