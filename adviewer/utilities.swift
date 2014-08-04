//
//  utilities.swift
//  adviewer
//
//  Created by James Carlson on 8/3/14.
//  Copyright (c) 2014 James Carlson. All rights reserved.
//

import Foundation

func pathFromURL(fileURL: String) -> String {
    
    return fileURL.stringByReplacingOccurrencesOfString("file://", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
}

func readStringFromPath(path: String) -> String {
    
    println("In readStringFromURL, FILE PATH: \(path)")
    
    return String.stringWithContentsOfFile(path, encoding: NSUTF8StringEncoding, error: nil)!
    
}


/****
htmlDocumentURL: Optional("file:///Users/carlson/Documents/abcdef.html")
In readStringFromURL, FILE PATH: /Users/carlson/Documents/abcdef.ad
env: ruby_executable_hooks: No such file or directory

http://askubuntu.com/questions/182418/how-to-get-usr-bin-env-ruby-to-point-to-the-correct-ruby-environment

???
gem install executable-hooks -v ">=1.3.2"
gem regenerate_binstubs

After ensuring I was in the right RVM Ruby
environment gem install rubygems-bundler did the trick.

****/

func refreshHTML(filePath: String) {
    
    let task = NSTask()
    task.launchPath = "/usr/bin/asciidoctor"
    task.arguments = [filePath]
    task.launch()
 
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