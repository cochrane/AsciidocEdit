//
//  Tools.swift
//  AsciidocEdit
//
//  Created by James Carlson on 11/5/14.
//  Copyright (c) 2014 James Carlson. All rights reserved.
//

import Foundation

class Tools {
    
    class func executeCommand(command: String, args: [String], verbose: Bool = false ) -> String {
            
            let task = NSTask()
            
            task.launchPath = command
            task.arguments = args
            
            
            if true {
                println("\nexecuteCommand")
                println("Running: \(command)")
                println("Args: \(args)\n")
            }
            
            let pipe = NSPipe()
            task.standardOutput = pipe
            task.launch()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output: String = NSString(data: data, encoding: NSUTF8StringEncoding)!
            
            if verbose {
                
                println("Output: \(output)")
                
            }
            
            return output
            
    }

    
    
}
