//
//  Mansucript.swift
//  AsciidocEdit
//
//  Created by James Carlson on 10/24/14.
//  Copyright (c) 2014 James Carlson. All rights reserved.
//

import Foundation

class Metadata {
    
    var dictionary: [String:String]?
    var fileName: String?
    var data: String?
    
    init( path: String ) {
        
    if fileExistsAtPath(path)  {
       data = readStringFromFile(path)
       dictionary = str2dict(data!)
    }

        
    }
    
    func print() {
        
        println("DICTIONARY")
        for key in dictionary!.keys {
            
            println("dict[\(key)] = \(dictionary![key])")
        }
    }
    
}

    
    
    
    
