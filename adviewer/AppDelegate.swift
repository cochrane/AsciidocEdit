//
//  AppDelegate.swift
//  adviewer
//
//  Created by James Carlson on 8/3/14.
//  Copyright (c) 2014 James Carlson. All rights reserved.
//

import Cocoa



class AppDelegate: NSObject, NSApplicationDelegate {


    @IBOutlet weak var asciidocController: AsciiDocController!
    
    

    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        
         asciidocController.setup()
       
    }
    
    
    func applicationWillTerminate(aNotification: NSNotification?) {
        
        // Insert code here to tear down your application
        
    }
    
   
    
    
}

