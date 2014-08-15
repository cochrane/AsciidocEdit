//
//  utilities.swift
//  adviewer
//
//  Created by James Carlson on 8/3/14.
//  Copyright (c) 2014 James Carlson. All rights reserved.
//

import Foundation




//MARK: User actions

func tempPath(path: String) -> String {
    
    let part = path.componentsSeparatedByString(".")
    return part[0]+"-temp."+part[1]
}

func preprocessFile(path: String) {
    
    // Get text from file and break it into lines
    let inputText = readStringFromPath(path)
    let jsContent = bundleContent("synchronize", "js")
    let lines = inputText.componentsSeparatedByString("\n")
    
    // Insert Javascript after header
    var output = ""
    var firstBlankLineFound = false
    for line in lines {
        
        output += line  + "\n"
        if line == "" && firstBlankLineFound == false {
            output += "\n"+jsContent+"\n\n"
            firstBlankLineFound = true
        }
    }
        
    let tmpPath = tempPath(path)
    
    // Write transformed text to temporary file
    output.writeToFile(tmpPath, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
    
}


func bundleContent(fileName: String, resourceType: String) -> String {
    

    let bundlePath = NSBundle.mainBundle().pathForResource(fileName, ofType: resourceType)
    let content = readStringFromPath(bundlePath)
    return content

}


func refreshHTML(filePath: String, htmlPath: String) {
    
    preprocessFile(filePath)
    
    println("filePath = \(filePath)")

    let tempADPath = tempPath(filePath)
    let tempHTMPath = tempPath(htmlPath)
    
    executeCommand("/usr/bin/asciidoctor", [tempADPath], verbose: false)
    executeCommand("/bin/mv", [tempHTMPath, htmlPath], verbose: false)
    executeCommand("/bin/rm", [tempADPath], verbose: false)
    
}

func saveAsPDF(filePath: String) {

    executeCommand("/usr/bin/asciidoctor-pdf", [filePath], verbose: true)
    
}

func saveAsEPUB3(filePath: String) {
    
    executeCommand("/usr/bin/asciidoctor-epub3", [filePath], verbose: true)
    
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

func htmlPathFromPath(path: String) -> String {
    
    let part = path.componentsSeparatedByString(".")
    return part[0] + ".html"
}

func pathFromURL(fileURL: String) -> String {
    
    return fileURL.stringByReplacingOccurrencesOfString("file://", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
}


func fileExistsAtPath(path: String) -> Bool {
    
    return NSFileManager.defaultManager().fileExistsAtPath(path)
    
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

func writeStringToFile(str: String, path: String) {
    
    str.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding, error: nil);
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


