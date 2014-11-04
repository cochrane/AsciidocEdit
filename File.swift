//
//  File.swift
//  AsciidocEdit
//
//  Created by James Carlson on 11/4/14.
//  Copyright (c) 2014 James Carlson. All rights reserved.
//

import Foundation

extension String {
   
    func segment(numberOfParts: Int) -> String {
        
        let components = self.pathComponents
        
        if components.count == 0 { return "" }
        
        var lastIndex = components.count - 1
        var firstIndex = 0
        
        if numberOfParts >= 0 {
            firstIndex = lastIndex - numberOfParts + 1
        } else {
            lastIndex += numberOfParts
        }
        if firstIndex <= lastIndex {
            let parts = Array(components[firstIndex...lastIndex])
            return parts.join("/")  // join(parts, separator: "/")
        }
        else {
            return ""
        }
        
    }
   
}