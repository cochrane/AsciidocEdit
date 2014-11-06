//
//  Dictionary.swift
//  AsciidocEdit
//
//  Created by James Carlson on 11/4/14.
//  Copyright (c) 2014 James Carlson. All rights reserved.
//

import Foundation

// require File


class StringDictionary {
    
    var dict = [:] as [String:String]
    var path : String
    
    init(path: String) {
        
        self.path = path
        println("path: \(self.path)")
    }
    
    // Read dictionary data from the file at path
    // and return the dictionary.  If there is
    // no file, return the empty dictionary
    func read() {
        
        if File.exists(path) {
            println("path: \(path)")
            println("FILE EXISTS")
            
            let data = File.read(path)
            
            println("DATA: \(data)")
            parse(data)
            
            println("DATA PARSE")
        }
    }
    
    func parse(str: String) {
        
        dict = [String:String]()
        
        let lines = str.componentsSeparatedByString("\n")
        
        for line in lines {
            
            var part = line.componentsSeparatedByString(":")
            if part.count == 2 {
                var key = part[0]
                var value = part[1].trim()
                dict[key] = value
            }
        }
        
    }
    
    func write() {
        
        var data = ""
        for key in dict.keys {
            data += "\(key): \(dict[key]!)\n"
        }
        
        File.write(data, path)
        
    }
    
    func print() {
        
        println("--------------------")
        for key in self.dict.keys {
            println("\(key): \(self.dict[key]!)")
        }
        println("--------------------")
        println("\(self.dict.count) items")
    }
    
    func value(key: String) -> String? {
        
        return dict[key]
        
    }
    
    func insert(#key: String, value: String) {
        
        if key != "" {
            
            dict[key] = value
            
        }
    }

    
}