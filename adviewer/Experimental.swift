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
    var audioList: [String]?
    var dictionary: [String: String]?
    
    
    init(filePath: String) {
        
        self.filePath = filePath
        
        
    }
    
    
    func load() {
        
        println("in Manifest, filePath =  \(self.filePath)")
        manifest = readStringFromFile(self.filePath)
        
        let dir = directoryPath(self.filePath)
        println("Directory path: \(dir)")
        
        getIncludeList()
        getImageList()
        getVideoList()
        getAudioList()
        self.dictionary = str2dict(DICTIONARY_FILE)
        
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
        println("\nIncludes (\(includeList!.count)): \(includeList!)")
        
    }
    
    func getImageList() {
        
        imageList = getAssetList("image")
        println("\nImages  (\(imageList!.count)): \(imageList!)")
    
    }
    
    func getVideoList() {
        
        videoList = getAssetList("video")
        println("\nVideos  (\(videoList!.count)): \(videoList!)")
    }
    
    func getAudioList() {
        
        audioList = getAssetList("audio")
        println("\nAudio Files  (\(audioList!.count)): \(audioList!)")
    }
    
    
    func gitURL() -> String {
        
        if let dict = dictionary {
        
            return "https://" + dict["github"]!
            
        } else {
        
            return ""
            
        }
    }
    
    func xclean(var x: String, assetType: String) -> String {
        
        x = x.stringByReplacingOccurrencesOfString("\(assetType)::", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        x = x.stringByReplacingOccurrencesOfString("[", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        return x
        
    }
    
    typealias str2strFun = (x: String) -> String
    

    
    func getAssetList(assetType: String) -> [String] {
        
        let clean = { (x: String) -> String in self.xclean(x, assetType: assetType)}
        
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
        
        return assetList
    }

   
    
}
