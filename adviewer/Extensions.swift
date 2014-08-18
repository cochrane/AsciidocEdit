//
//  Extensions.swift
//  AsciidocEdit
//
//  Created by James Carlson on 8/18/14.
//  Copyright (c) 2014 James Carlson. All rights reserved.
//

import Foundation


extension String {
    
    func substringWithNSRange(range:NSRange)->String {
        let begin = advance(self.startIndex, range.location),
        finish = advance(self.endIndex, range.location+range.length-countElements(self))
        return self.substringWithRange(Range(start:begin, end:finish))
    }
}

extension String {
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
}