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

class SourceFile: CustomStringConvertible, CustomDebugStringConvertible {
    @inlinable var contents: String { file.contents }

    let file:     File
    let filename: String
    lazy var bytes: Data = contents.data(using: .utf8)!

    init(filename: String) throws {
        self.filename = filename
        guard let f = File(path: self.filename) else { throw StreamError.FileNotFound(description: self.filename) }
        self.file = f
    }

    lazy private(set) var strings: [SourceItem] = {
        guard let m1 = data["key.syntaxmap"] as? [[String: Any]] else { return [] }
        var arr: [SourceItem] = []
        for m2 in m1 {
            if let kind = m2["key.kind"] as? String, kind == "source.lang.swift.syntaxtype.string", let off = m2["key.offset"] as? Int64, let len = m2["key.length"] as? Int64 {

                let s = String(data: bytes[Int(off) ..< Int(off + len)], encoding: .utf8)!

                arr <+ SourceItem(kind: .kString, range: NSRange(location: Int(off - 1), length: Int(len)), in: contents)
            }
        }
        return arr
    }()
    lazy private(set) var data: [String: SourceKitRepresentable] = {
        do { return try Request.editorOpen(file: file).send() }
        catch { fatalError(error.localizedDescription) }
    }()
    lazy private(set) var json: String = {
        do { return String(data: try JSONSerialization.data(withJSONObject: toNSDictionary(data), options: [ .prettyPrinted, .sortedKeys ]), encoding: .utf8)! }
        catch { fatalError(error.localizedDescription) }
    }()
    lazy private(set) var description: String = json
    lazy private(set) var debugDescription: String = {
        guard let arr = data["key.substructure"] as? [[String: Any]] else { return "" }
        var out: String = ""
        let str: String = file.contents

        func debugArray(_ arr: [[String: Any]], indent: String) {
            out += "\(indent)+---------------------------------------------------------------------------------------------------------------------------------\n"
            for map in arr {
                debugMap(map, indent: indent)
            }
        }

        func debugMap(_ map: [String: Any], indent: String) {
            for e1 in map {
                out += "\(indent)|  Key: \(e1.key)\n"

                if let arr = e1.value as? [[String: Any]] {
                    debugArray(arr, indent: "\(indent)|      ")
                }
                else if let _map = e1.value as? [String: Any] {
                    debugMap(_map, indent: "\(indent)|      ")
                }
                else {
                    out += "\(indent)|     : \(e1.value)\n"
                }
            }
            if let offset = map["key.offset"] as? Int64, let length = map["key.length"] as? Int64 {
                multilineArea(section: " Sub", offset: offset, length: length, indent: indent)
            }
            if let offset = map["key.bodyoffset"] as? Int64, let length = map["key.bodylength"] as? Int64 {
                multilineArea(section: "Body", offset: offset, length: length, indent: indent)
            }
            if let offset = map["key.nameoffset"] as? Int64, let length = map["key.namelength"] as? Int64 {
                let nsRange = NSRange(location: Int(offset > 0 ? offset - 1 : offset), length: Int(length))
                let range   = Range<String.Index>(nsRange, in: str)!
                out += "\(indent)| Name: \"\(str[range])\"\n"
            }

            out += "\(indent)+---------------------------------------------------------------------------------------------------------------------------------\n"
        }

        func multilineArea(section: String, offset: Int64, length: Int64, indent: String) {
            out += "\(indent)| \(section):\n"
            out += "\(indent)|      +=======================================================================================================================================\n"
            let lines = str[Range<String.Index>(NSRange(location: Int(offset > 0 ? offset - 1 : offset), length: Int(length)), in: str)!].split(on: "\\R")
            for l in lines { out += "\(indent)|      | \(l)\n" }
            out += "\(indent)|      +=======================================================================================================================================\n"
        }

        debugArray(arr, indent: "")
        return out
    }()
    lazy private(set) var keys: Set<String> = {
        var set: Set<String> = []

        func foo(_ map: [String: Any]) {
            for e in map {
                set.insert(e.key)
                if let m = e.value as? [String: Any] { foo(m) }
                else if let a = e.value as? [[String: Any]] { bar(a) }
            }
        }

        func bar(_ arr: [[String: Any]]) {
            for m in arr { foo(m) }
        }

        if let arr = data["key.substructure"] as? [[String: Any]] { bar(arr) }
        return set
    }()
}
