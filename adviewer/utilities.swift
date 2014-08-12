//
//  utilities.swift
//  adviewer
//
//  Created by James Carlson on 8/3/14.
//  Copyright (c) 2014 James Carlson. All rights reserved.
//

import Foundation




//MARK: User actions


func refreshHTML(filePath: String) {
    
    let cmd = "/usr/bin/asciidoctor"
    
    let version = executeCommand(cmd, ["-V"], verbose: false)
    
    println("\n----------------------")
    println(version)
    executeCommand(cmd, [filePath], verbose: false)
    println("----------------------\n")
 
}

func saveAsPDF(filePath: String) {
    
    let cmd = "/usr/bin/asciidoctor-pdf"

    
    executeCommand(cmd, [filePath], verbose: true)
    
    
}

func installAsciidoctor() {
    
    executeCommand("/bin/echo", ["foo", "bar"], verbose: true)
    
    // executeCommand("rvm", ["use", "system"], verbose: true)
    executeCommand("/usr/bin/gem", ["install", "asciidoctor"], verbose: true)
    
   
    
}



//MARK: File system

func baseName(path: String) -> String {
    
    //let part = path.pathComponents
    let part = path.componentsSeparatedByString(".")
    return part[0]
    
}

func pathFromURL(fileURL: String) -> String {
    
    return fileURL.stringByReplacingOccurrencesOfString("file://", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
}

func readStringFromPath(path: String) -> String {
    
    println("In readStringFromURL, FILE PATH: \(path)")
    
    let str = String.stringWithContentsOfFile(path, encoding: NSUTF8StringEncoding, error: nil)!
    
    return str
    
}

func documentsDirectory() -> String? {
    
    let dirs : [String]? = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as? [String]
    
    var documentsDirectory: String?
    
    
    
    if let directories = dirs {
        
        if directories.count > 0 {
            
            documentsDirectory = directories[0]
            
        }
        
    }
    
    println("documentsDirectory: \(documentsDirectory)")
    
    return documentsDirectory

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

//MARK: Memorize and recall key-value pairs

func memorizeKeyValuePair(key: String, value: String) {
    
    NSUserDefaults.standardUserDefaults().setObject(value, forKey:key)
    NSUserDefaults.standardUserDefaults().synchronize()
    println("Memorized: \(key) => \(value)")
    
}

func recallValueOfKey(key: String) -> String? {
    
    let value = NSUserDefaults.standardUserDefaults().objectForKey(key) as String?
    println("Recalled: \(key) => \(value)")
    return value

}

//MARK: External command execution

func executeCommand(command: String, args: [String], verbose: Bool = false ) -> String {
    
    let task = NSTask()
    
    task.launchPath = command
    task.arguments = args
    
    
    if verbose {
        println("executeCommand")
        println("Running: \(command)")
        println("Args: \(args)")
    }
    
    let pipe = NSPipe()
    task.standardOutput = pipe
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output: String = NSString(data: data, encoding: NSUTF8StringEncoding)
    
    if verbose {
        
        println("Output: \(output)")
        
    }
    
    return output
    
}


//MARK: Extensions

extension String {
    
    func countWords() -> Int {
        
        let word = self.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        return word.count
    }
}


