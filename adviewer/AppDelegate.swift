//
//  AppDelegate.swift
//  adviewer
//
//  Created by James Carlson on 8/3/14.
//  Copyright (c) 2014 James Carlson. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
                            
    @IBOutlet weak var window: NSWindow!

    @IBOutlet weak var scrollView: NSScrollView!
    
    @IBOutlet var textView: NSTextView!
    
    var documentPath: String?
    var documentText: String = ""

    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        
        // testFS()
        
        textView.string = "foo"
        
        
        scrollView.drawsBackground = true
        scrollView.backgroundColor = NSColor.lightGrayColor()
        
    
        
        // textView.textContainer
        
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }


    @IBAction func newFileAction(sender: AnyObject) {
        
        println("FOO")
    }
    
    
    @IBAction func openFileAction(sender: AnyObject) {
    
        let panel = NSOpenPanel()
        
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        
        panel.allowsMultipleSelection = false // yes if more than one dir is allowed
        
        let clicked = panel.runModal()
        
        if (clicked == NSFileHandlingPanelOKButton) {
            
            for url in panel.URLs {
              if let documentURL = url.absoluteString {
                documentPath = pathFromURL(documentURL)
                documentText = readStringFromPath(documentPath!)
                textView.string = documentText
              }
            }
        }
        
    }
    
    
    @IBAction func closeFileAction(sender: AnyObject) {
    }
    
    @IBAction func saveFileAction(sender: AnyObject) {
        
        println("SaveFileAction (1)")
        println("documentPath = \(documentPath)")
        
        if let currentDocumentPath = documentPath {
            
            println("SaveFileAction (2)")
            
            documentText = textView.string
            
            println("\nin saveFileAction, \ndocumentText:\n----------\n\(documentText)\n----------")
            
            documentText.writeToFile(currentDocumentPath,
                atomically: false, encoding: NSUTF8StringEncoding, error: nil)
        }
        
    }
    
    
    @IBOutlet weak var saveAsFileAction: NSMenuItem!
   
    
    
    
}

