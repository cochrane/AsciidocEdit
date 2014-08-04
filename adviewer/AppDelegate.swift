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
    
    @IBOutlet weak var messageLabel: NSTextField!
    
    var documentURL: String?
    var htmlDocumentURL: String?
    var documentPath: String?
    var documentText: String = ""

    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        
        // testFS()
        

        let frame = NSMakeRect(0.0, 0.0, 1200.0, 700.0)
        window.setFrame(frame, display: true)
        window.backgroundColor = NSColor.blackColor()
        
        textView.string = "foo"
        textView.font = NSFont(name: "Helvetica", size: 18.0)
        textView.automaticSpellingCorrectionEnabled = false
        textView.backgroundColor =  NSColor(SRGBRed: 0.96, green: 0.9, blue: 0.8, alpha: 1.0)
        
        adWebView.UIDelegate = self
        messageLabel.stringValue = ""
        
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
                
                updateUI()
                
                // http://lapcatsoftware.com/blog/2006/11/19/the-webview-reloaded/
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
            
            updateUI()
            
        }
        
    }
    
    
    @IBOutlet weak var saveAsFileAction: NSMenuItem!
   
    
    
    func updateUI() {
        
        refreshHTML(documentPath!)
        adWebView.mainFrameURL = htmlDocumentURL!
        adWebView.reload(nil)
        messageLabel.stringValue = "Word count: \(documentText.countWords())"
        
    }
    
    
}


// adWebView.mainFrame.setNeedsDisplay()

// adWebView.reload(nil)

// adWebView.mainFrame.reload()

/*
if adWebView.mainFrame.dataSource == nil {

adWebView.mainFrame.reload()

// adWebView.mainFrame.loadRequest(<#request: NSURLRequest?#>)

} else {

// adWebView.super().reload(nil)
}
*/

/*
if ([[self mainFrame] dataSource] == nil) {
[[self mainFrame] loadRequest:myRequest];
} else {
[super reload:sender];
}
*/

// http://lapcatsoftware.com/blog/2006/11/19/the-webview-reloaded/
// adWebView.setNeedsDisplayInRect(nil)

