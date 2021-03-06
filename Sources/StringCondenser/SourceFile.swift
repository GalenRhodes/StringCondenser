/*****************************************************************************************************************************//**
 *     PROJECT: StringCondenser
 *    FILENAME: SourceFile.swift
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: October 23, 2021
 *
  * Permission to use, copy, modify, and distribute this software for any purpose with or without fee is hereby granted, provided
 * that the above copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR
 * CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
 * NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *//*****************************************************************************************************************************/

import Foundation
import CoreFoundation
import Rubicon
import SourceKittenFramework
import System

class SourceFile {
    let file:     File
    let filename: String
    lazy private(set) var contents: ByteOffsetString = ByteOffsetString(file.contents)

    init(filename: String) throws {
        if #available(macOS 12, *) {
            self.filename = FilePath(filename).lexicallyNormalized().string
        }
        else {
            let fn = filename.replacingAll(pattern: "\\\\", template: "/")
            self.filename = (fn.hasPrefix("/") ? fn : ("\(FileManager.default.currentDirectoryPath)/\(fn)")).replacingAll(pattern: "//|/\\./", template: "/")
        }

        guard let f = File(path: self.filename) else { throw StreamError.FileNotFound(description: self.filename) }
        self.file = f
    }
}
