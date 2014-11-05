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

    let toolBox = ["ASCIIDOCTOR", "ASCIIDOCTOR_PDF", "ASCIIDOCTOR_EPUB", "GET_NOTEBOOK", "PREPROCESS_TEX", "MAKE_ASCII"]
    let newSettings: StringDictionary
    var installed = [:] as [String:Bool]
    
    init(path: String) {
        
        self.newSettings = StringDictionary(path: path)
        self.newSettings.read()

    }
    
    
    func setupTool(tool: String) -> Bool {
        
        
        // If there is a new location for the tool, try to load it
        if newSettings.value(tool) != nil && File.exists(newSettings.value(tool)!) {
            
            memorizeKeyValuePair(tool, newSettings.value(tool)!)
            installed[tool] = true
            println("\(tool) installed with NEW SETTNG")
            return true
        
        }
        
        // Otherwise, try to load the tool from location used last time
        if recallValueOfKey(tool) != nil && File.exists(recallValueOfKey(tool)!) {
            
            installed[tool] = true
            println("\(tool) installed with OLD SETTNG")
            return true
        
        }
        
        // Fail
        installed[tool] = false
        println("\(tool) NOT installed")
        return false
        
    }
    
    func setup() -> Bool {
        
        var toolChainComplete = true
    
        for tool in toolBox {
            
            let result = setupTool(tool)
            toolChainComplete = result && toolChainComplete
            
        }
        
        return toolChainComplete
    }
    
    
    
    func run(tool: String, _ args: [String], verbose: Bool = true) -> (Bool, String) {
        
        if installed[tool] != nil {
            
            let toolPath = recallValueOfKey(tool)
            let output = Toolchain.executeCommand(toolPath!, args, verbose: verbose)
            return (true, output)
            
        } else { return (false, "") }
        
    }
    
    
    
    class func executeCommand(command: String, _ args: [String], verbose: Bool = false ) -> String {
            
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
