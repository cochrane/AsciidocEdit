//
//  Tools.swift
//  AsciidocEdit
//
//  Created by James Carlson on 11/5/14.
//  Copyright (c) 2014 James Carlson. All rights reserved.
//

import Foundation

// requires -- a userDictionary, the functions memorizeKeyValuePair, recallValueOfKey

class Toolchain {

    var dict : StringDictionary  // holds pairs lke "ASCIIDOCTOR", '/usr/local/bin/asciidoctor
    
    init(path: String) {
        
        self.dict = StringDictionary(path: path)
        self.dict.read()

    }
    
    func run(tool: String, args: [String], verbose: Bool) -> Bool {
        
        if installed(tool) {
            
            var toolPath = dict.value(tool)!
            Toolchain.executeCommand(toolPath, args: args, verbose: verbose)
            return true
            
        } else {
            
            return false
        }
        
    }
    
    
    
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
    
    
    // transer key-value pairs from userDictionary
    // to NSUserDefaults and return status
    // FORMERLY: copyKeyValuePairToNSUserDefaults
    func memorize(tool: String) -> Bool {
        
        if dict.value(tool) == nil {
            
            return false
            
        } else {
            
            memorizeKeyValuePair(tool, dict.value(tool)!)
            return true
            
        }
        
    }
    
    
    func installed(tool: String) -> Bool {
    
        if let cmd = dict.value(tool) {
            
            return File.exists(cmd)
            
        } else {
            
            return false
        }
        
    }
    
    func install(tool: String) -> Bool {
        
        
        // Ensure that tool neme and location are remembered if valid
        if dict.value(tool) != nil {
          memorizeKeyValuePair(tool, dict.value(tool)!)
          println("Memorized: \(tool)")
        } else {
            return false
        }
        
        return installed(tool)
        
    }
    
    
    func check() -> Bool {
        
        var toolchainLoaded = true
        
        println("\nChecking toolchain ...")
        
        for tool in dict.dict.keys {
            
            let result = install(tool)
            if result == true {
                println("\(tool) loaded")
            } else {
                println("\(tool) NOT FOUND")
            }
            toolchainLoaded = result && toolchainLoaded
        }
        
        if toolchainLoaded {
            
            println("Toolchain is loaded")
            memorizeKeyValuePair("toolchainLoaded", "yes")
            
        } else {
            
            memorizeKeyValuePair("toolchainLoaded", "no")
            println("Toolhcain incomplete")
        }
        
        return toolchainLoaded
        
    }
    
    
}
