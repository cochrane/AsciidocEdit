//
//  AppDelegate.swift
//  adviewer
//
//  Created by James Carlson on 8/3/14.
//  Copyright (c) 2014 James Carlson. All rights reserved.
//

import Cocoa
import WebKit


class AppDelegate: NSObject, NSApplicationDelegate {
                            
    @IBOutlet weak var window: NSWindow!

    @IBOutlet weak var scrollView: NSScrollView!
    
    @IBOutlet var textView: NSTextView!
    
    @IBOutlet weak var adWebView: WebView!
    
    var documentURL: String?
    var htmlDocumentURL: String?
    var documentPath: String?
    var documentText: String = ""

    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        
        // testFS()
        

        let frame = NSMakeRect(0.0, 0.0, 1400.0, 700.0)
        window.setFrame(frame, display: true)
        window.backgroundColor = NSColor.darkGrayColor()
        
        textView.string = "foo"
        textView.font = NSFont(name: "Helvetica", size: 18.0)
        
       // init(name fontName: String!, size fontSize: CGFloat)
        textView.automaticSpellingCorrectionEnabled = false
        textView.backgroundColor =  NSColor(SRGBRed: 0.96, green: 0.9, blue: 0.8, alpha: 1.0)
        // NSColor.lightGrayColor()
        
        scrollView.drawsBackground = true
        scrollView.backgroundColor = NSColor(SRGBRed: 1.0, green: 0.8, blue: 0.8, alpha: 1.0)
        
        
        
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
              if let url = url.absoluteString {
                
                documentURL = url
                htmlDocumentURL = baseName(documentURL!) + ".html"
                documentPath = pathFromURL(documentURL!)
                
                println("\ndocumentURL: \(documentURL)")
                println("\nhtmlDocumentURL: \(htmlDocumentURL)")
                
                documentText = readStringFromPath(documentPath!)
                textView.string = documentText
                
                // refreshHTML(documentPath!)
                let commandOutput = executeCommand("/bin/echo", ["Hello, I am here!"])
                println("Command output: \(commandOutput)")
                
                adWebView.mainFrameURL = htmlDocumentURL!
              }
            }
        }
        
    }
    
    
    @IBAction func closeFileAction(sender: AnyObject) {
    }
    
    @IBAction func saveFileAction(sender: AnyObject) {
        
        if let currentDocumentPath = documentPath {
            
            documentText = textView.string
            
            documentText.writeToFile(currentDocumentPath,
                atomically: false, encoding: NSUTF8StringEncoding, error: nil)
        }
        
    }
    
    
    @IBOutlet weak var saveAsFileAction: NSMenuItem!
   
    
    
    
}

