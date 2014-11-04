//
//  File.swift
//  AsciidocEdit
//
//  Created by James Carlson on 11/4/14.
//  Copyright (c) 2014 James Carlson. All rights reserved.
//

import Foundation


class File {
    
    class func pathLength(path: String) -> Int {
        
        let components = path.pathComponents
        return components.count
        
    }
    
    
    // File.segment("User/carlson/Desktop/foo/bar.html", numberOfParts: 1)
    // => bar.html
    // File.segment("User/carlson/Desktop/foo/bar.html", numberOfParts: 2)
    // => foo/bar.html
    // File.segment("User/carlson/Desktop/foo/bar.html", numberOfParts: -1)
    // => User/carlson/Desktop/foo"
    class func segment(path: String, _ parts: Int) -> String {
        
        let components = path.pathComponents
        
        if components.count == 0 { return "" }
        
        var lastIndex = components.count - 1
        var firstIndex = 0
        
        if parts >= 0 {
            firstIndex = lastIndex - parts + 1
        } else {
            lastIndex += parts
        }
        if firstIndex <= lastIndex {
            let elements = Array(components[firstIndex...lastIndex])
            return elements.join("/")
        }
        else {
            return ""
        }
        
    }
    
    // Assumes parts > 0
    // File.pathTail("a/b/c/d.txt", parts: 2) => "c/d.txt"
    class func pathTail(path: String, _ parts: Int) -> String {
    
        return File.segment(path, parts)
    }
    
    // Assumes parts > 0
    // File.pathTail("a/b/c/d.txt", parts: 2) => "a/b"
    class func pathHead(path: String, _ parts: Int) -> String {
        
        return File.segment(path, -parts)
    }
    
    // File.parent("a/b/c/d", parts: 2) => "a/b/c"
    class func parent(path: String, parts: Int = 1) -> String {
        
        let n = File.pathLength(path)
        return File.pathHead(path, 1)
    }
    
    class func file_in_parent(path: String) -> String {
        
        let parent_directory = File.parent(File.parent(path))
        let file = File.pathTail(path, 1)
        return parent_directory + "/" + file
        
    }

    
    // "a/b/c/d.txt" => "d.txt"
    class func baseName(path: String) -> String {
        
        return File.segment(path, 1)
    }
    
    class func extName( path: String ) -> String {
        
        if isDirectory(path) {return "" }
        let parts = File.segment(path, 1).componentsSeparatedByString(".")
        var result = ""
        if parts.count == 2 { result = parts[1] }
        return result
    }
    
    class func directoryOf(path: String) -> String {
        
        return File.segment(path, -1)
        
    }
    
    class func exists(path: String) -> Bool {
        
        return NSFileManager.defaultManager().fileExistsAtPath(path)
        
    }
    
    //////////////////////
    
    class func ls(directoryPath: String  ) -> [String] {
        
        let fm = NSFileManager.defaultManager()
        
        let fileArray = fm.contentsOfDirectoryAtPath(directoryPath, error: nil) as [String]
        
        return fileArray
        
    }
    
    class func documentsDirectory() -> String? {
        
        var documentsDirectory: String?
        
        if let dirs = directories() {
            
            if dirs.count > 0 {
                
                documentsDirectory = dirs[0]
                
            }
            
        }
        
        return documentsDirectory
    }
    
    class func directories() -> [String]? {
        
        return NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as? [String]
    }
    
    
    /////////////////////
    
    
    class func read(path: String) -> String {
        
        // let str = File.read(pathToFile, encoding: NSStringEncoding)
        return  String(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil)!
        // XXX: This nees to be dealt with: we should return an Optional
        // let str = String.stringWithContentsOfFile(pathToFile)
        
        // return str
        
    }
    
    class func write(str: String, _ path: String) {
        
        str.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding, error: nil);
    }


    
}