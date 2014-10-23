//
//  utilities.swift
//  adviewer
//
//  Created by James Carlson on 8/3/14.
//  Copyright (c) 2014 James Carlson. All rights reserved.
//


let ASCIIDOCTOR = "/Users/carlson/.rbenv/shims/asciidoctor"
let ASCIIDOCTOR_PDF = "/Users/carlson/.rbenv/shims/asciidoctor-pdf"
let ASCIIDOCTOR_EPUB3 = "/Users/carlson/.rbenv/shims/asciidoctor-epub3"
let PREPROCESS_TEX = "/usr/local/bin/preprocess_tex"
let GET_NOTEBOOK = "/Users/carlson/Dropbox/bin2/get_notebook"

import Foundation

/*
class File {
    
    class func exists (path: String) -> Bool {
        return NSFileManager().fileExistsAtPath(path)
    }
    
    class func read (path: String, encoding: NSStringEncoding = NSUTF8StringEncoding) -> String? {
        if File.exists(path) {
            return NSString(contentsOfFile: path, encoding:NSUTF8StringEncoding, error: nil)!
        }
        
        return nil
    }
    
    class func write (path: String, content: String, encoding: NSStringEncoding = NSUTF8StringEncoding) -> Bool {
        return content.writeToFile(path, atomically: true, encoding: encoding, error: nil)
    }
}

*/


/*

let read : String? = File.read("/path/to/file.txt")

println(read)

let write : Bool = File.write("/path/to/file2.txt", content: "String to write")

println(write)

*/

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


// Retrieve content of file in bundle
func bundleContent(fileName: String, resourceType: String) -> String {
    

    let bundlePath = NSBundle.mainBundle().pathForResource(fileName, ofType: resourceType)
    let content = readStringFromFile(bundlePath!)
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
    
    var innerUseLatexMode = false
    
    var test_content = readStringFromFile(tempADPath)
    if test_content.contains(":latex:") {
        
        innerUseLatexMode = true
    }
    
    //if true {
   if innerUseLatexMode {
        
        executeCommand(PREPROCESS_TEX, [tempADPath, tempADPath])
        var content = readStringFromFile(tempADPath)
        content = ":stem: latexmath\n" + content
        println("\n\n====================")
        println("CONTENT:")
        println("====================")
        println(content)
        println("====================\n\n")
        writeStringToFile(content, tempADPath)
        
        
    }
    executeCommand(ASCIIDOCTOR, [tempADPath])
    executeCommand("/bin/mv", [tempHTMLPath, htmlPath])
    executeCommand("/bin/rm", [tempADPath])
    
}

func saveAsPDF(filePath: String) {

    executeCommand(ASCIIDOCTOR_PDF, [filePath], verbose: true)
    
}

func saveAsEPUB3(filePath: String) {
    
    executeCommand(ASCIIDOCTOR_EPUB3, [filePath])
    
}

func fetchNotebookFromURL(url: String) {
    
    // executeCommand("pwd", [], verbose: true
    executeCommand(GET_NOTEBOOK, [url])
    
}



func fetchNotebook(path: String) -> String {
    
    let currentDirectory = directoryOfPath(path)
    let configFile = join([currentDirectory, "config"], separator: "/")
    var message = ""
    var output = ""
    
    if !fileExistsAtPath(configFile) { return "Could not fetch notebook (no config file)" }
    
    let defaults = readStringFromFile(configFile)
    println("DEFAULTS: \(defaults)")
    let dict = str2dict(defaults)
    let notebook_url = dict["remote_notebook"]
   
    if notebook_url != nil {
        println ("NOTEBOOK URL: \(notebook_url!)")
        executeCommand("/usr/bin/cd", [currentDirectory], verbose: true)
        executeCommand("/bin/pwd", [], verbose: true)
        output = executeCommand(GET_NOTEBOOK, [notebook_url!, currentDirectory], verbose: true)
        
        let pattern = ".ad"
        let number_of_ad_files = pattern.match(output).count - 3
        message = "Fetched \(number_of_ad_files) files from " + notebook_url!
    }
    
    return message
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
    
    // Handle case of /User/foo/bar
    
    var startIndex = 0
    
    if array[0] == separator {
        
        startIndex = 1
        
    }
    
    
    for element in array[startIndex..<lastIndex] {
        
        str += element + separator
        
    }
    
    str += array[lastIndex]
    
    // Handle case of /User/foo/bar
    if startIndex == 1 {
        
        str = separator + str
    }
    
    return str
}

// Return dictionary from string of the form
// str = "foo:23\nbar:87". Thus dict = str2dict(str)
// yields dict with dict["foo"] = 23, etc.
func str2dict(str: String) ->[String: String] {
    
    var dict = [String:String]()
    
    let lines = str.componentsSeparatedByString("\n")
    
    for line in lines {
        
        var part = line.componentsSeparatedByString(":")
        if part.count == 2 {
          var key = part[0]
          var value = part[1]
          dict[key] = value
        }
    }
    
    return dict
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

// shortPath("User/carlson/Desktop/foo/bar.html", numberOfParts: 1)
// shortPath("User/carlson/Desktop/foo/bar.html", numberOfParts: 2)
// shortPath("User/carlson/Desktop/foo/bar.html", numberOfParts: -1)
func shortPath(path: String, numberOfParts: Int = 2) -> String {
    
    let components = path.pathComponents

    if components.count == 0 { return "" }
    
    var lastIndex = components.count - 1
    var firstIndex = 0
    
    if numberOfParts >= 0 {
        firstIndex = lastIndex - numberOfParts + 1
    } else {
        lastIndex += numberOfParts
    }
    if firstIndex <= lastIndex {
      let parts = Array(components[firstIndex...lastIndex])
      return join(parts, separator: "/")
    }
    else {
        return ""
    }
    
}


func directoryOfPath(path: String) -> String {
   
    return shortPath(path, numberOfParts: -1)
    
}

func baseName(path: String) -> String {
    
    let part = path.componentsSeparatedByString(".")
    let result = part[0]
    return result
}

func htmlPath(documentPath: String) -> String {
    
    let part = documentPath.componentsSeparatedByString(".")
    let result = part[0] + ".html"
    
    println("+++ htmlPath: \(result)")
    
    return result
    
}

func htmlURL(documentPath: String) -> String {
    
    let part = documentPath.componentsSeparatedByString(".")
    
    let result = "file://" + part[0] + ".html"
    
    println("+++ htmlURL: \(result)")
    
    return result
    
}

func documentURL(documentPath: String) -> String {
    
    let result = "file://" + documentPath

    println("+++ documentURL: \(result)")
    
    return result
    

    
}


func pathFromURL(fileURL: String) -> String {
    
    let result = fileURL.stringByReplacingOccurrencesOfString("file://", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
    
    println("+++ pathFromURL: \(result)")
    
    return result
    
    
}


func fileExistsAtPath(path: String) -> Bool {
    
    return NSFileManager.defaultManager().fileExistsAtPath(path)
    
}

func readStringFromFile(pathToFile: String) -> String {

    // let str = File.read(pathToFile, encoding: NSStringEncoding)
    let str = String.stringWithContentsOfFile(pathToFile)
    
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

func filesInDirectory(directoryPath: String  ) -> [String] {
    
    let fm = NSFileManager.defaultManager()
    
    let fileArray = fm.contentsOfDirectoryAtPath(directoryPath, error: nil) as [String]
    
    return fileArray
   
}

    

func cleanHTML(directoryPath: String) {
    
    
    println("directoryPath = \(directoryPath)")
    
    let fileArray = filesInDirectory(directoryPath)
    
    for file in fileArray {
        
        let path = directoryPath + "/" + file
        let ext = path.pathExtension
        
        if ext == "html" {
        
            println("REMOVED: \(path)")
            executeCommand("/bin/rm", [path])
            
    
        }
        
    }
    
    
}

func generateIncludeList(masterFilePath: String)-> [String] {
    
    
    println("masterFilePath = \(masterFilePath)")
    
    let masterDirectoryPath = directoryPath(masterFilePath)
    
    let fileArray = filesInDirectory(masterDirectoryPath)
    
    var array = [String]()
    
    for file in fileArray {
        
        let path = masterDirectoryPath + "/" + file
        let ext = path.pathExtension
        
        if ext == "ad" && path != masterFilePath {
            
           array.append(file)
            
        }
        
    }
    
    return array
    
}

//MARK: Memorize and recall key-value pairs

func memorizeKeyValuePair(key: String, value: String) {
    
    NSUserDefaults.standardUserDefaults().setObject(value, forKey:key)
    NSUserDefaults.standardUserDefaults().synchronize()
    println("Memorized: \(key) => \(value)")
    
}

func recallValueOfKey(key: String) -> String? {
    
    if let value = NSUserDefaults.standardUserDefaults().objectForKey(key) as String? {
      println("Recalled: \(key) => \(value)")
      return value
    }
    else {
       println("Recalled: \(key)is NIL")
       return ""
    }

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
    let output: String = NSString(data: data, encoding: NSUTF8StringEncoding)!
    
    if verbose {
        
        println("Output: \(output)")
        
    }
    
    return output
    
}

//MARK: Extras

func dictionaryFromFile(path: String) -> [String: String] {
    
    let data = readStringFromFile(path)
    let lines = data.componentsSeparatedByString("\n")
    var dict = [String: String]()
    for line in lines {
        
        let part = line.componentsSeparatedByString(":")
        if part.count == 2 {
          dict[part[0]] = part[1]
          println("key = [\(part[0])], value = [\(part[1])]")
        }
    }
    
    return dict
    
    
}

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


