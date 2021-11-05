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

class ByteOffsetString: Hashable, Equatable, Comparable, BidirectionalCollection, Codable, CustomDebugStringConvertible, CustomStringConvertible {

    private enum CodingKeys: String, CodingKey { case string, start, end }

    typealias Element = Character
    typealias Index = Int64
    typealias SubSequence = ByteOffsetString

    lazy private(set) var description: String = String(_substring)

    typealias CacheItem = (stringIndex: StringIndex, offset: Int64)
    typealias IndexOfResult = (elem: CacheItem?, cIdx: Int)

    private let _range: Range<Int64>
    private let _str:   String
    private var _cache: [CacheItem] = []
    lazy private var _strRange:  Range<StringIndex> = (indexFor(offset: _range.lowerBound) ..< indexFor(offset: _range.upperBound))
    lazy private var _substring: Substring          = _str[_strRange]

    convenience init(_ str: String) {
        self.init(str, range: 0 ..< Int64(str.utf8.count))
    }

    /// Constructor
    ///
    /// - Parameters:
    ///   - str:
    ///   - range:
    private init(_ str: String, range: Range<Int64>) {
        self._str = str
        self._range = range
    }

    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        _str = try c.decode(String.self, forKey: .string)
        _range = (try c.decode(Int64.self, forKey: .start) ..< c.decode(Int64.self, forKey: .end))
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(_str, forKey: .string)
        try c.encode(_range.lowerBound, forKey: .start)
        try c.encode(_range.upperBound, forKey: .end)
    }

    subscript(bounds: Range<Index>) -> SubSequence {
        guard bounds != _range else { return self }
        guard bounds.isInside(_range) else { fatalError("Range is out of bounds.") }
        return ByteOffsetString(_str, range: bounds)
    }

    subscript(position: Index) -> Element { _str[indexFor(offset: position)] }

    func index(before i: Index) -> Index {
        guard i > startIndex else { fatalError("Index out of bounds.") }
        return i - 1
    }

    func index(after i: Index) -> Index {
        guard i < endIndex else { fatalError("Index out of bounds.") }
        return i + 1
    }

    private func indexFor(offset: Int64) -> StringIndex {
        /*-------------------------------------------------------
         * Offset must not be less than zero.
         *-------------------------------------------------------*/
        guard offset >= 0 else { fatalError("Offset out of bounds.") }
        /*-------------------------------------------------
         * If the index is equal to zero then return the
         * start index.
         *------------------------------------------------*/
        guard offset > 0 else { return _str.startIndex }
        /*------------------------------------------------
         * See if the index for the given offset is
         * already cached. If so, return it. If not then
         * the tuple contains the index (cIdx) where the
         * cached item should have been.
         -------------------------------------------------*/
        let r: IndexOfResult = cachedIndexFor(offset: offset)
        if let i = r.elem { return i.stringIndex }
        /*-------------------------------------------------------
         * Get the cached index for the closest offset that
         * occurs before this one. That might be the first index
         * (offset zero).
         *-------------------------------------------------------*/
        var (xIdx, xOffset): CacheItem = (r.cIdx > 0 ? (_cache[r.cIdx - 1].stringIndex, _cache[r.cIdx - 1].offset) : (_str.startIndex, Int64.zero))
        /*-------------------------------------------------------
         * Advance to the index for this offset, cache it, and
         * then return it.
         *-------------------------------------------------------*/
        repeat {
            guard xOffset < offset else {
                _cache.insert(CacheItem(stringIndex: xIdx, offset: offset), at: r.cIdx)
                return xIdx
            }
            guard xIdx < _str.endIndex else { fatalError("Offset out of bounds.") }
            xOffset += Int64(_str[xIdx].utf8.count)
            _str.formIndex(after: &xIdx)
        }
        while true
    }

    /*==========================================================================================================*/
    /// Get a cached index for a given offset. This method will perform a binary search of the
    /// cache array.
    ///
    /// - Parameters:
    ///   - offset: The offset.
    ///   - left: The left bounds.
    ///   - right: The right bounds.
    /// - Returns: A tuple that contains the cache item and the index in the cache array
    ///            where it was found or a `nil` value and the index where the cached item
    ///            should have been found.
    ///
    private func cachedIndexFor(offset: Int64, left: Int, right: Int) -> IndexOfResult {
        guard left <= right else { return (nil, left) }
        let mid = (((right - left) / 2) + left)
        let e   = _cache[mid]

        if e.offset == offset {
            return (e, mid)
        }
        else if e.offset < offset {
            return cachedIndexFor(offset: offset, left: mid + 1, right: right)
        }
        else {
            return cachedIndexFor(offset: offset, left: left, right: mid - 1)
        }
    }
}

extension ByteOffsetString {
    @inlinable var startIndex:       Index { _range.lowerBound }
    @inlinable var endIndex:         Index { _range.upperBound }
    @inlinable var debugDescription: String { description }

    /*==========================================================================================================*/
    /// Get a cached index for a given offset. This method will perform a binary search of the
    /// cache array.
    ///
    /// - Parameter offset: The offset.
    /// - Returns: A tuple that contains the cache item and the index in the cache array
    ///            where it was found or a `nil` value and the index where the cached item
    ///            should have been found.
    ///
    @inlinable func cachedIndexFor(offset: Int64) -> IndexOfResult { cachedIndexFor(offset: offset, left: _cache.startIndex, right: _cache.endIndex - 1) }

    @inlinable func hash(into hasher: inout Hasher) { hasher.combine(_str) }

    @inlinable static func == (lhs: ByteOffsetString, rhs: ByteOffsetString) -> Bool { lhs._str == rhs._str }

    @inlinable static func < (lhs: ByteOffsetString, rhs: ByteOffsetString) -> Bool { lhs._str < rhs._str }

    @inlinable static func == (lhs: String, rhs: ByteOffsetString) -> Bool { lhs == rhs._str }

    @inlinable static func < (lhs: String, rhs: ByteOffsetString) -> Bool { lhs < rhs._str }

    @inlinable static func == (lhs: ByteOffsetString, rhs: String) -> Bool { lhs._str == rhs }

    @inlinable static func < (lhs: ByteOffsetString, rhs: String) -> Bool { lhs._str < rhs }

    @inlinable static func + (lhs: ByteOffsetString, rhs: ByteOffsetString) -> String { lhs._str + rhs._str }

    @inlinable static func + (lhs: String, rhs: ByteOffsetString) -> String { lhs + rhs._str }

    @inlinable static func + (lhs: ByteOffsetString, rhs: String) -> String { lhs._str + rhs }

    @inlinable static func += (lhs: inout String, rhs: ByteOffsetString) { lhs = (lhs + rhs) }
}
