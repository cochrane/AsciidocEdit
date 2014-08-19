//
//  utilities.swift
//  adviewer
//
//  Created by James Carlson on 8/3/14.
//  Copyright (c) 2014 James Carlson. All rights reserved.
//

import Foundation




//MARK: User helpers


// Return path for temporary file
func tempFile(path: String) -> String {
    
    let part = path.componentsSeparatedByString(".")
    return part[0]+"-temp."+part[1]
}


// Inject resource into temporary file copy
func inject(pathToFile: String, payloadName: String, payloadType: String) {
    
    // Get text from file and break it into lines
    let inputText = readStringFromFile(pathToFile)
    let jsContent = bundleContent(payloadName, payloadType)
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
        
    let tmp = tempFile(pathToFile)
    
    // Write transformed text to temporary file
    output.writeToFile(tmp, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
    
}


// Retrieve contentof file in bundle
func bundleContent(fileName: String, resourceType: String) -> String {
    

    let bundlePath = NSBundle.mainBundle().pathForResource(fileName, ofType: resourceType)
    let content = readStringFromFile(bundlePath)
    return content

}



// (1) Inject "synchonize.js" after first non-blank line of
// the file at asciidocPath and write it to a temporary 
// copy. (2) Apply asciidoctor to the temporary file.
// (3) Remove the temporary files.
func refreshHTML(asciidocPath: String, htmlPath: String, useLaTexMode: Bool = false) {
    
    inject(asciidocPath, "synchronize", "js")
    
    let tempADPath = tempFile(asciidocPath)
    let tempHTMLPath = tempFile(htmlPath)
    
    
    if useLaTexMode {
        
        executeCommand("/usr/local/bin/tex_mode_preprocess", [tempADPath, tempADPath])
        var content = readStringFromFile(tempADPath)
        content = ":stem: latexmath\n" + content
        println("\n\n====================")
        println("CONTTENT:")
        println("====================")
        println(content)
        println("====================\n\n")
        writeStringToFile(content, tempADPath)
        
        
    }
    executeCommand("/usr/bin/asciidoctor", [tempADPath])
    executeCommand("/bin/mv", [tempHTMLPath, htmlPath])
    executeCommand("/bin/rm", [tempADPath])
    
}

func saveAsPDF(filePath: String) {

    executeCommand("/Users/carlson/Dropbox/prog/git/asciidoctor-pdf/bin/asciidoctor-pdf", [filePath], verbose: true)
    
}

func saveAsEPUB3(filePath: String) {
    
    executeCommand("/usr/bin/asciidoctor-epub3", [filePath])
    
}

func installAsciidoctor() {
    
    executeCommand("/bin/echo", ["foo", "bar"])
    executeCommand("/usr/bin/gem", ["install", "asciidoctor"])
    
}


//MARK: Strings

// join(["foo", "bar"], separator: "+") = "foo+bar"
func join(array: [String], separator: String = "") -> String {
    
    let lastIndex  = array.count - 1
    
    var str = ""
    
    for element in array[0..<lastIndex] {
        
        str += element + separator
        
    }
    
    str += array[lastIndex]
    
    return str
}

//MARK: File system


// directoryPath("aa/bb/cc.txt") = "aa/bb"
func directoryPath(path: String) -> String {
    
    let components = path.pathComponents
    let lastIndex = components.count - 1
    let foo = Array(components[0..<lastIndex])
    return join(foo, separator: "/")
    
}

//MARK: File system

func shortPath(path: String, numberOfParts: Int = 2) -> String {

    let components = path.pathComponents
    let lastIndex = components.count - 1
    var firstIndex = lastIndex - numberOfParts + 1
    if firstIndex < 0 { firstIndex = 0 }
    let parts = Array(components[firstIndex...lastIndex])
    return join(parts, separator: "/")

}

func baseName(path: String) -> String {
    
    let part = path.componentsSeparatedByString(".")
    return part[0]
    
}

func htmlPath(documentPath: String) -> String {
    
    let part = documentPath.componentsSeparatedByString(".")
    return part[0] + ".html"
    
}

func htmlURL(documentPath: String) -> String {
    
    let part = documentPath.componentsSeparatedByString(".")
    
    return "file:///" + part[0] + ".html"
    
}

func documentURL(documentPath: String) -> String {
    
    return "file:///" + documentPath
    
}


func pathFromURL(fileURL: String) -> String {
    
    return fileURL.stringByReplacingOccurrencesOfString("file://", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
}


func fileExistsAtPath(path: String) -> Bool {
    
    return NSFileManager.defaultManager().fileExistsAtPath(path)
    
}

func readStringFromFile(pathToFile: String) -> String {

    
    let str = String.stringWithContentsOfFile(pathToFile, encoding: NSUTF8StringEncoding, error: nil)!
    
    return str
    
}

func writeStringToFile(str: String, path: String) {
    
    str.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding, error: nil);
}

func directories() -> [String]? {
    
    return NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as? [String]
}

func documentsDirectory() -> String? {
    
    var documentsDirectory: String?
    
    if let dirs = directories() {
        
        if dirs.count > 0 {
            
            documentsDirectory = dirs[0]
            
        }
        
    }
    
    return documentsDirectory
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

//MARK: Extras

func setLatexMode(content: String) -> Bool {
    
    
    let status = content.contains(":latex:")
    
    println("\nLATEX: \(status)")
    
    return status
    
}


//MARK: Extensions

extension String {
    
    func countWords() -> Int {
        
        let word = self.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        return word.count
    }
}


