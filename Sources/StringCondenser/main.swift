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

struct StringCondenser: ParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Condense string literals into global variables.")

    @Option(name: [ .long, .customShort("d") ], help: "The directory to search for source files.") /*        */ var sourceDirectory:    String
    @Option(name: [ .long, .customShort("a") ], help: "The filename of the backup TAR file.") /*             */ var archiveFile:        String = "SourceBackup.tar.bz2"
    @Option(name: [ .long, .customShort("m") ], help: "The name of the source file with the global variables.") var messagesSourceFile: String = "Messages.swift"

    mutating func run() throws {
        let _msgSrcFile = FileManager.default.
        print("    Source Directory: \(sourceDirectory)")
        print("    Archive Filename: \(archiveFile)")
        print("Messages Source File: \(_msgSrcFile)")

        let files: [String] = try FileManager.default.directoryFiles(atPath: sourceDirectory) { path, file, attrs in
            let fn = "\(path)/\(file)"
            guard fn != _msgSrcFile else { return false }
            guard fn.hasSuffix(".swift") else { return false }
            print("\"\(fn)\"")
            return true
        }
    }
}

DispatchQueue.main.async { StringCondenser.main(); exit(0) }
dispatchMain()
