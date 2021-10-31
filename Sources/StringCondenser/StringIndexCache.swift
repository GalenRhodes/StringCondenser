/*===============================================================================================================================================================================*
 *     PROJECT: StringCondenser
 *    FILENAME: StringIndexCache.swift
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 10/31/21
 *
 * Copyright © 2021. All rights reserved.
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

class StringIndexCache {
    let str:   String
    var cache: [Element] = []

    init(_ str: String) { self.str = str }

    subscript(offset: Int64) -> StringIndex {
        guard offset > 0 else { return str.startIndex }
        let r: IndexOfResult = indexOf(offset: offset)
        if let i = r.elem { return i.stringIndex }

        var (xIdx, xOffset) = (r.cIdx > 0 ? (cache[r.cIdx - 1].stringIndex, cache[r.cIdx - 1].offset) : (str.startIndex, Int64.zero))

        repeat {
            if xOffset == offset {
                cache.insert(Element(offset: offset, stringIndex: xIdx), at: r.cIdx)
                return xIdx
            }
            let ch: Character = str[xIdx]
            let chsz: Int = ch.utf8.count
            xOffset += Int64(chsz)
            if xOffset >= offset {
                cache.insert(Element(offset: offset, stringIndex: xIdx), at: r.cIdx)
                return xIdx
            }
            str.formIndex(after: &xIdx)
        }
        while xIdx < str.endIndex

        fatalError("Offset out of bounds.")
    }

    typealias IndexOfResult = (elem: Element?, cIdx: Int)

    func indexOf(offset: Int64) -> IndexOfResult {
        var left = cache.startIndex
        var right = cache.endIndex

        while left <= right {
            let mid = (((right - left) / 2) + left)
            let e = cache[mid]

            if e.offset == offset { return (e, mid) }
            else if e.offset < offset { left = (mid + 1) }
            else { right = mid }
        }

        return (nil, right)
    }

    struct Element: Comparable, Equatable, Hashable {
        let offset:      Int64
        let stringIndex: StringIndex

        func hash(into hasher: inout Hasher) { hasher.combine(offset) }

        static func < (lhs: StringIndexCache.Element, rhs: StringIndexCache.Element) -> Bool { lhs.offset < rhs.offset }

        static func == (lhs: StringIndexCache.Element, rhs: StringIndexCache.Element) -> Bool { lhs.offset == rhs.offset }
    }
}
