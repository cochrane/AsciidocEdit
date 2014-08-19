//
//  Experimental.swift
//  AsciidocEdit
//
//  Created by James Carlson on 8/19/14.
//  Copyright (c) 2014 James Carlson. All rights reserved.
//

import Foundation

class Manifest {
    
    let filePath: String
    var manifest: String?
    var includeList: [String]?
    var imageList: [String]?
    var videoList: [String]?
    
    
    init(filePath: String) {
        
        self.filePath = filePath
        
        
    }
    
    func load() {
        
        manifest = readStringFromFile(self.filePath)
        
        let dir = directoryPath(self.filePath)
        println("Directory path: \(dir)")
        
        
    }
    
    func getIncludeList() {
        
        func clean(var x: String) -> String {
            
            x = x.stringByReplacingOccurrencesOfString("include::", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            x = x.stringByReplacingOccurrencesOfString("[", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            return x
        
        }
        
        let includeRx = "include::.*\\["
        var array = includeRx.match(manifest!)
        includeList = array.map(clean)
        println("\nIncludes:\n\(includeList!)")
        
    }
    
    func getImageList() {
        
        func clean(var x: String) -> String {
            
            x = x.stringByReplacingOccurrencesOfString("image::", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            x = x.stringByReplacingOccurrencesOfString("[", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            return x
            
        }

        
        let dir = directoryPath(self.filePath)
        
        imageList = [String]()
        
        for file in includeList! {
            
            let path = dir + "/" + file
            let contents = readStringFromFile(path)
            
            let imageRx = "image::.*\\["
            var array = imageRx.match(contents) as [String]
            array = array.map(clean)
            imageList = imageList! + array
            
            
        }
        println("\nImages:\n\(imageList!)\n")
    }
    
    func getVideoList() {
        
        func clean(var x: String) -> String {
            
            x = x.stringByReplacingOccurrencesOfString("video::", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            x = x.stringByReplacingOccurrencesOfString("[", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            return x
            
        }
        
        
        let dir = directoryPath(self.filePath)
        
        videoList = [String]()
        
        for file in includeList! {
            
            let path = dir + "/" + file
            let contents = readStringFromFile(path)
            
            let videoRx = "video::.*\\["
            var array = videoRx.match(contents) as [String]
            array = array.map(clean)
            videoList = videoList! + array
            
            
        }
        println("\nVideos:\n\(videoList!)\n")
    }
    
    func getAssetList(assetType: String) -> [String] {
        
        func _clean(var x: String, assetType: String) -> String {
            
            x = x.stringByReplacingOccurrencesOfString("video::", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            x = x.stringByReplacingOccurrencesOfString("[", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            return x
            
        }
        
        func clean(var x: String) -> String {
            
            return _clean(x, assetType)
        }
        
        
        let dir = directoryPath(self.filePath)
        
        var assetList = [String]()
        
        for file in includeList! {
            
            let path = dir + "/" + file
            let contents = readStringFromFile(path)
            
            let assetRx = "\(assetType)::.*\\["
            var array = assetRx.match(contents) as [String]
            array = array.map(clean)
            assetList = assetList + array
            
            
        }
        println("\n\(assetType)s:\n\(assetList)\n")
        
        return assetList
    }

    
    
}
