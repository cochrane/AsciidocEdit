//
//  utilities.swift
//  adviewer
//
//  Created by James Carlson on 8/3/14.
//  Copyright (c) 2014 James Carlson. All rights reserved.
//

import Foundation


extension String {
    
    func countWords() -> Int {
        
        let word = self.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        return word.count
    }
}

func pathFromURL(fileURL: String) -> String {
    
    return fileURL.stringByReplacingOccurrencesOfString("file://", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
}

func readStringFromPath(path: String) -> String {
    
    println("In readStringFromURL, FILE PATH: \(path)")
    
    let str = String.stringWithContentsOfFile(path, encoding: NSUTF8StringEncoding, error: nil)!
    
    return str
    
}


func refreshHTML(filePath: String) {
    
    let task = NSTask()
    task.launchPath = "/usr/bin/asciidoctor"
    task.arguments = [filePath]
    task.launch()
    println("Refreshed \(filePath)")
 
}

func executeCommand(command: String, args: [String]) -> String {
    
    let task = NSTask()
    
    task.launchPath = command
    task.arguments = args
    
    let pipe = NSPipe()
    task.standardOutput = pipe
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output: String = NSString(data: data, encoding: NSUTF8StringEncoding)
    
    return output
    
}

func baseName(path: String) -> String {
    
    //let part = path.pathComponents
    let part = path.componentsSeparatedByString(".")
    return part[0]
    
}


func testFS() {
    
    let file = "test_file.txt"

    let dirs : [String]? = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as? [String]

    if let directories = dirs {
        // let directories:String[] = dirs;
        let dir = directories[0]; //documents directory
        let path = dir.stringByAppendingPathComponent(file);
        let text = "some text"
        
        //writing
        text.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding, error: nil);
        
        
        println("the string [\(text)] was written to \(file)")
        
        //reading
        let text2 = String.stringWithContentsOfFile(path, encoding: NSUTF8StringEncoding, error: nil)
        
        println("the string [\(text2)] was read from \(file)")
        
        
        
    }
}