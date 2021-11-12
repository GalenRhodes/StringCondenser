/*===============================================================================================================================================================================*
 *     PROJECT: StringCondenser
 *    FILENAME: StringProtocol+StringCondenser.swift
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 11/12/21
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

extension StringProtocol {

    @inlinable func replacingAll(pattern: String, template: String, count: inout Int) -> String {
        var error: Error? = nil
        guard let rx = RegularExpression(pattern: pattern, error: &error) else { fatalError(error!.localizedDescription) }
        let (s, c) : (String, Int) = rx.stringByReplacingMatches(in: self, withTemplate: template)
        count = c
        return s
    }

    @inlinable func replacingAll(pattern: String, template: String) -> String {
        var c: Int = 0
        return replacingAll(pattern: pattern, template: template, count: &c)
    }

    @inlinable func contains(pattern: String) -> Bool {
        var error: Error? = nil
        guard let rx = RegularExpression(pattern: pattern, error: &error) else { fatalError(error!.localizedDescription) }
        return rx.firstMatch(in: self) != nil
    }

}
