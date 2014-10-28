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
let DICTIONARY_FILE = "config"

import Foundation


func packageIsInstalled(packageKey: String) -> Bool {
    
    if let cmd = recallValueOfKey(packageKey) {
        
        
        println("package installed: \(packageKey)")
        
        return fileExistsAtPath(cmd)
        
    } else {
        
         println("package NOT installed: \(packageKey)")
        
        return false
    }
    
}

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
func injectFromBundle(inputPath: String, outputPath: String, payloadName: String, payloadType: String) {
    
    
    // Get text from file and break it into lines
    let inputText = readStringFromFile(inputPath)
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
    
    // Write transformed text to temporary file
    output.writeToFile(outputPath, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
   
}

// Inject payload into temporary file copy
func injectFromFile(inputPath: String, outputPath: String, payloadPath: String) {
    
    // Get text from file and break it into lines
    let inputText = readStringFromFile(inputPath)
    let payload = readStringFromFile(payloadPath)
    let lines = inputText.componentsSeparatedByString("\n")
    
    // Insert Javascript after header
    var output = ""
    var firstBlankLineFound = false
    for line in lines {
        
        output += line  + "\n"
        if line == "" && firstBlankLineFound == false {
            output += "\n"+payload+"\n\n"
            firstBlankLineFound = true
        }
    }
    
    // Write transformed text to temporary file
    output.writeToFile(outputPath, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
    
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
// refreshHTML goes here
func refreshHTML(asciidocPath: String, htmlPath: String, manuscript:  Manuscript!) {
    
    let preprocess_cmd = recallValueOfKey("PREPROCESS_TEX")
    let asciidoctor_cmd = recallValueOfKey("ASCIIDOCTOR")
    
    
    let tmp = tempFile(asciidocPath)
    injectFromBundle(asciidocPath, tmp, "synchronize", "js")
    
    println("MACRO FILE: \(manuscript.macro_path())")

    if  fileExistsAtPath(manuscript.macro_path()) { injectFromFile(tmp, tmp, manuscript.macro_path()) }
    
    let tempADPath = tempFile(asciidocPath)
    let tempHTMLPath = tempFile(htmlPath)

    
    var innerUseLatexMode = false
    
    var test_content = readStringFromFile(tempADPath)
    if test_content.contains(":latex:") {
        
        innerUseLatexMode = true
    }
    
    if innerUseLatexMode {
        
        var content = ""
        
        if packageIsInstalled("PREPROCESS_TEX") {
          executeCommand(preprocess_cmd!, [tempADPath, tempADPath])
          content = readStringFromFile(tempADPath)
          content = ":stem: latexmath\n" + content
        } else {
           content = readStringFromFile(tempADPath)
        }
        writeStringToFile(content, tempADPath)
        
        
    }
    
    if packageIsInstalled("ASCIIDOCTOR") {
        executeCommand(asciidoctor_cmd!, [tempADPath])
        executeCommand("/bin/mv", [tempHTMLPath, htmlPath])
        executeCommand("/bin/rm", [tempADPath])
    }
    
}



func saveAsPDF(filePath: String) {
    
    if packageIsInstalled("ASCIIDOCTOR_PDF") {

        executeCommand(ASCIIDOCTOR_PDF, [filePath], verbose: true)
    
    }
    
}

func saveAsEPUB3(filePath: String) {

    if packageIsInstalled("ASCIIDOCTOR_EPUB") {
        
        executeCommand(ASCIIDOCTOR_EPUB3, [filePath])
        
    }
    
}

func fetchNotebookFromURL(url: String) {
    
    if packageIsInstalled("GET_NOTEBOOK") {
        
        executeCommand(GET_NOTEBOOK, [url])
    }
    
}


// return path for default dictionary 
// given the current document path
func dictionaryPath(docPath: String) -> String {
    
    let currentDirectory = directoryOfPath(docPath)
    return join([currentDirectory, DICTIONARY_FILE], separator: "/")

}

// Read dictionary data from the file at path
// and return the dictionary.  If there is
// no file, return the empty dictionary
func readDictionary(path: String) -> [String: String] {
    
    
    if fileExistsAtPath(path) {
        
        let data = readStringFromFile(path)
        return str2dict(data)
        
    } else {
        
        return [:]
        
    }

}

func writeDictionary(path: String, dict: [String:String]) {
    
    let currentDirectory = directoryOfPath(path)
    let configFile = join([currentDirectory, DICTIONARY_FILE], separator: "/")
   
     var data = ""
    for key in dict.keys {
        data += "\(key): \(dict[key]!)\n"
    }
    
    writeStringToFile(data, path)
    
}



func fetchNotebook(notebook_url: String, directory: String) -> String {
  
        // executeCommand("/usr/bin/cd", [directory], verbose: true)
        // executeCommand("/bin/pwd", [], verbose: true)
        // var output = executeCommand(GET_NOTEBOOK, [notebook_url, directory], verbose: true)
    
    ASCIIDOCTOR_EPUB3
        var output = executeCommand(GET_NOTEBOOK, [notebook_url, directory], verbose: true)
        
        let pattern = ".ad"
        let number_of_ad_files = pattern.match(output).count - 3
        return "Fetched \(number_of_ad_files) files from " + notebook_url
  
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
          var value = part[1].trim()
          dict[key] = value
        }
    }
    
    return dict
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

func printDictionary(dict: [String:String]) {
    
    println("\n--------------------")
    for key in dict.keys {
        println("\(key): \(dict[key]!)")
    }
    println("--------------------\n\(dict.count) items")
}

