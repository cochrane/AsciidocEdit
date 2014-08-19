//
//  Extensions.swift
//  AsciidocEdit
//
//  Created by James Carlson on 8/18/14.
//  Copyright (c) 2014 James Carlson. All rights reserved.
//

import Foundation


extension String {
    
    subscript (i: Int) -> String {
        return String(Array(self)[i])
    }
    
    
    subscript (r: Range<Int>) -> String {
        var start = advance(startIndex, r.startIndex)
            var end = advance(startIndex, r.endIndex)
            return substringWithRange(Range(start: start, end: end))
    }
    
    func substringWithNSRange(range:NSRange)->String {
        let begin = advance(self.startIndex, range.location),
        finish = advance(self.endIndex, range.location+range.length-countElements(self))
        return self.substringWithRange(Range(start:begin, end:finish))
    }

    func contains(other: String) -> Bool{
        var start = startIndex
        
        do{
            var subString = self[Range(start: start++, end: endIndex)]
            if subString.hasPrefix(other){
                return true
            }
            
        }while start != endIndex
        
        return false
    }
    
    func containsIgnoreCase(other: String) -> Bool{
        var start = startIndex
        
        do{
            var subString = self[Range(start: start++, end: endIndex)].lowercaseString
            if subString.hasPrefix(other.lowercaseString){
                return true
            }
            
        }while start != endIndex
        
        return false
    }
    
    
    
    func match( str: String) -> [String] {
        
        var err: NSError?
        let regex = NSRegularExpression(pattern: self, options: NSRegularExpressionOptions(0), error: &err)
        if err != nil {
            return [String]()
        }
        let nsstr = str as NSString
        let all = NSRange(location: 0, length: nsstr.length)
        var matches = [String]()
        regex.enumerateMatchesInString(str, options: NSMatchingOptions(0), range: all) {
            (result: NSTextCheckingResult!, _, _) in matches.append(nsstr.substringWithRange(result.range))
        }
        return matches
    }
    
    // Example: 
    // let text = "image::foo.png[float=left] ho ho ho, this is a test\n Line 2, blah, blah, image::bar[float=right, width=200]"
    // let ImageRx = "image::.*\\[.*\\]"
    // ImageRx.match(text) 
    // "image::foo.png[float=left]", "image::bar[float=right, width=200]"]

    
    
}