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
    return foo.join("/")
    
}


func isDirectory(path: String) -> Bool {
    
    if path.pathComponents.last == "/" {
        return true
    } else {
        return false
    }
}




//MARK: File system





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











 