//
//  FileUtilities.swift
//  AsciidocEdit
//
//  Created by James Carlson on 10/27/14.
//  Copyright (c) 2014 James Carlson. All rights reserved.
//

import Foundation


//MARK: File system


// directoryPath("aa/bb/cc.txt") = "aa/bb"
func directoryPath(path: String) -> String {
    
    let components = path.pathComponents
    let lastIndex = components.count - 1
    let foo = Array(components[0..<lastIndex])
    return join(foo, separator: "/")
    
}

func extName( path: String ) -> String {
    
    if isDirectory(path) {return "" }
    let parts = shortPath(path, numberOfParts: 1).componentsSeparatedByString(".")
    var result = ""
    if parts.count == 2 { result = parts[1] }
    return result
}

func isDirectory(path: String) -> Bool {
    
    if path.pathComponents.last == "/" {
        return true
    } else {
        return false
    }
}




//MARK: File system


// shortPath("User/carlson/Desktop/foo/bar.html", numberOfParts: 1)
// => bar.html
// shortPath("User/carlson/Desktop/foo/bar.html", numberOfParts: 2)
// => foo/bar.html
// shortPath("User/carlson/Desktop/foo/bar.html", numberOfParts: -1)
// => User/carlson/Desktop/foo"
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


func pathFromURL(url: String) -> String {
    
    if url.contains("file://") {
        
        return url.stringByReplacingOccurrencesOfString("file://", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
    }
    
    if url.contains("http://") {
        
        return url.stringByReplacingOccurrencesOfString("http://", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
    }
    
    return url
    
}


func fileExistsAtPath(path: String) -> Bool {
    
    return NSFileManager.defaultManager().fileExistsAtPath(path)
    
}

func file_in_parent(path: String) -> String {
    
    let parent_directory = shortPath(path, numberOfParts: -2)
    let file = shortPath(path, numberOfParts: 1)
    return parent_directory + "/" + file
    
}

func readStringFromFile(path: String) -> String {
    
    // let str = File.read(pathToFile, encoding: NSStringEncoding)
    return  String(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil)!
    // XXX: This nees to be dealt with: we should return an Optional
    // let str = String.stringWithContentsOfFile(pathToFile)
    
    // return str
    
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

 