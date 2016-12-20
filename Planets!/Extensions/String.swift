//
//  String.swift
//  demo
//
//  Created by Robert-Hein Hooijmans on 08/11/16.
//  Copyright © 2016 Robert-Hein Hooijmans. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    func substring(_ location: Int, _ length: Int) -> String? {
        guard location + length <= characters.count else { return nil }
        
        let sub = String(characters.dropFirst(location))
        let index = sub.index(sub.startIndex, offsetBy: length)
        return sub.substring(to: index)
    }
    
    func syllables() -> [Syllable] {
        var syllables = characters.map { Syllable.Vowel($0) }
        syllables.append(.Suffix)
        return syllables
    }
}

extension NSMutableAttributedString {
    
    func addAttributes(_ attrs: [String : Any], enclosingTag: String) {
        
        let length = self.length
        var range = NSRange(location: 0, length: length)
        var ranges: [NSRange] = []
        
        while range.location != NSNotFound {
            range = (string as NSString).range(of: enclosingTag as String, options: NSString.CompareOptions.caseInsensitive, range: range, locale: Locale.current)
            
            if range.location != NSNotFound {
                ranges.append(range)
                range = NSRange(location: range.location + range.length, length: length - (range.location + range.length))
            }
        }
        
        var offset = 0
        var previousRange = NSRange(location: 0, length: 0)
        
        ranges.forEach { range in
            deleteCharacters(in: NSRange(location: range.location - offset, length: range.length))
            
            if NSEqualRanges(previousRange, NSRange(location: 0, length: 0)) {
                previousRange = range
            } else {
                addAttributes(attrs, range: NSRange(location: previousRange.location - offset + enclosingTag.characters.count, length: range.location - previousRange.location - enclosingTag.characters.count))
                previousRange = NSRange(location: 0, length: 0)
            }
            
            offset += range.length
        }
    }
}
