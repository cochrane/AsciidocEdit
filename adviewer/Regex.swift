//
//  regex.swift
//  AsciidocEdit
//
//  Created by James Carlson on 11/5/14.
//  Copyright (c) 2014 James Carlson. All rights reserved.
//

import Foundation



prefix operator / { }

prefix func / (pattern:String) -> NSRegularExpression {
    var options: NSRegularExpressionOptions =
    NSRegularExpressionOptions.DotMatchesLineSeparators
    
    return NSRegularExpression(pattern:pattern,
        options:options, error:nil)!
}

infix operator =~ { }

func =~ (left: String, right: NSRegularExpression) -> Bool {
    let matches = right.numberOfMatchesInString(left,
        options: nil,
        range: NSMakeRange(0, left.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)))
    return matches > 0
}


/***


// http://nomothetis.svbtle.com/clean-regular-expressions-using-conversions


let alpha = "math, \\[\na^2 + b^2\n\\], ho ho!"
println(alpha)
alpha =~ /"\\[.*\\]"


***/

