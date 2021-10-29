/*===============================================================================================================================================================================*
 *     PROJECT: StringCondenser
 *    FILENAME: Collection+StringCondenser.swift
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 10/26/21
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

extension Collection where Element == String {
    var commonPrefix: String {
        guard isNotEmpty else { return "" }
        var str: String       = first!

        forEach { (other: String) -> Void in
            var i1 = str.startIndex
            var i2 = other.startIndex

            while i1 < str.endIndex && i2 < other.endIndex {
                guard str[i1] == other[i2] else { break }
                str.formIndex(after: &i1)
                other.formIndex(after: &i2)
            }
            if i1 < str.endIndex {
                str = String(str[str.startIndex ..< i1])
            }
        }

        return str
    }
}
