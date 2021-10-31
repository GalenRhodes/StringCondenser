/*===============================================================================================================================================================================*
 *     PROJECT: StringCondenser
 *    FILENAME: SourceItem.swift
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 10/24/21
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

class SourceItem: CustomStringConvertible {
    enum ItemKind: String {
        case kString
        case kComment
        case kIdentifier
    }

    let kind:    ItemKind
    let nsRange: NSRange
    let str:     String

    init(kind: ItemKind, range: NSRange, in str: String) {
        self.kind = kind
        self.nsRange = range
        self.str = str
    }

    private(set) lazy var description: String = { "[ Kind: \"%s\"; Offset: %d; Length: %d; Value: \"%s\" ]".format(kind, nsRange.location, nsRange.length, str) }()
}
