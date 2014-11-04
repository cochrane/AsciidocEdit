//
//  ArrayExtensions.swift
//  AsciidocEdit
//
//  Created by James Carlson on 11/4/14.
//  Copyright (c) 2014 James Carlson. All rights reserved.
//

import Foundation

extension Array {
    
    func join(separator: String) -> String {
        let lastIndex  = self.count - 1
        var result = ""
        for element in self[0..<lastIndex] {
            result += (element as String) + separator
        }
        result += self[lastIndex] as String
        return result
    }
    
}

