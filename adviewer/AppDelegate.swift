//
//  AppDelegate.swift
//  adviewer
//
//  Created by James Carlson on 8/3/14.
//  Copyright (c) 2014 James Carlson. All rights reserved.
//

import Cocoa
import WebKit



class AppDelegate: NSObject, NSApplicationDelegate, NSTextViewDelegate {
                            
    @IBOutlet weak var window: NSWindow!

    @IBOutlet weak var scrollView: NSScrollView!
    
    @IBOutlet var textView: NSTextView!
    
    @IBOutlet weak var adWebView: WebView!    
    
    @IBOutlet weak var messageLabel: NSTextField!
    
    var documentURL: String?
    var htmlDocumentURL: String?
    var documentPath: String?
    var documentText: String = ""
    var textChanges: Int = 0
    var textLength = 0
    
    func processNotification(notification: NSNotification) {
        
        println("Notification: \(notification)")
        
    }

    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        
        let nc = NSNotificationCenter()
        nc.addObserver(self, selector: "processNotification", name: nil, object: nil)

        let frame = NSMakeRect(0.0, 0.0, 1200.0, 700.0)
        window.setFrame(frame, display: true)
        window.backgroundColor = NSColor.blackColor()
        window.title = "AsciiHelper"
        
        textView.string = "foo"
        textView.font = NSFont(name: "Helvetica", size: 18.0)
        
        textView.automaticSpellingCorrectionEnabled = false
        textView.automaticDashSubstitutionEnabled = false
        textView.automaticQuoteSubstitutionEnabled = false
    
        
        textView.backgroundColor =  NSColor(SRGBRed: 0.96, green: 0.9, blue: 0.8, alpha: 1.0)
        
        textView.delegate = self
        adWebView.UIDelegate = self
        
        
       //  adWebView.mainFrame.loadHTMLString("javascript:testEcho('Hello World!')");
        
        
        adWebView.mainFrame.loadRequest(NSURLRequest(URL: NSURL(string: htmlDocumentURL)))
        // adWebView.shouldUpdateWhileOffscreen = true

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
                
                /*
                documentURL = url
                htmlDocumentURL = baseName(documentURL!) + ".html"
                documentPath = pathFromURL(documentURL!)
                */
                
                synchronizePaths(url)
                
                println("\ndocumentURL: \(documentURL)")
                println("\nhtmlDocumentURL: \(htmlDocumentURL)")
                
                documentText = readStringFromPath(documentPath!)
                textView.string = documentText
                
                updateUI(refresh: false)
                
                // http://lapcatsoftware.com/blog/2006/11/19/the-webview-reloaded/
              }
            }
        }
        
    }
    
    
    @IBAction func closeFileAction(sender: AnyObject) {
    }
    
    @IBAction func saveFileAction(sender: AnyObject) {
        
        if let currentDocumentPath = documentPath {
            
            updateDocument(currentDocumentPath)
            updateUI(refresh: true)
            
        }
        
    }
    
    @IBAction func SaveAsPDFAction(sender: AnyObject) {
        
        saveAsPDF(documentPath!)
        
    }
    
    
    func updateDocument(path: String) {
        
        documentText = textView.string
        
        documentText.writeToFile(path,
            atomically: false, encoding: NSUTF8StringEncoding, error: nil)
 
    }
    

    @IBAction func browserBack(sender: AnyObject) {
        
        adWebView.goBack()
    }
   
    
    @IBAction func browserForward(sender: AnyObject) {
        
        adWebView.goForward()
        
    }
    
    
    @IBAction func aboutAsciidoctorAction(sender: AnyObject) {
        
        let cmd = "/usr/bin/asciidoctor"
        
        let raw_version = executeCommand(cmd, ["-V"], verbose: false)
        let part = raw_version.componentsSeparatedByString("\n")
        let version = part[0]
        
        
        messageLabel.stringValue = version
        messageLabel.needsDisplay = true

        
    }
    
    
    @IBAction func installAsciidoctorAction(sender: AnyObject) {
        
        installAsciidoctor()
    }
    
    
    func updateUI(#refresh: Bool) {
        
        
        if refresh {
            
            println("-- writing to file: \(documentPath)")
            
            if let currentDocumentPath = documentPath {
                
                updateDocument(currentDocumentPath)
                
            }
            
            refreshHTML(documentPath!)
            
        }
        
        let win = adWebView.windowScriptObject
        let location: AnyObject! = win.valueForKey("location")
        let href: AnyObject! = location.valueForKey("href");
        
        println("location: \(location)")
        println("href: \(href)")
        
        adWebView.mainFrame.loadRequest(NSURLRequest(URL: NSURL(string: htmlDocumentURL)))
        // adWebView.mainFrame.reload()
        adWebView.mainFrameURL = htmlDocumentURL!
        // adWebView.reload(nil)
        // adWebView.setNeedsDisplayInRect(adWebView.frame)
        adWebView.needsDisplay = true
        
        messageLabel.stringValue = "Word count: \(documentText.countWords())"
        messageLabel.needsDisplay = true
        
        
        // adWebView.scrollPoint(NSPoint(x:0, y:200))
            // scrollView.contentOffset = CGPointMake(0, 100);
        
        window.viewsNeedDisplay = true
    }
    
    func synchronizePaths(url: String) {
        
        documentURL = url
        htmlDocumentURL = baseName(documentURL!) + ".html"
        documentPath = pathFromURL(documentURL!)
    }
    
    func textDidChange (notification: NSNotification) {
        
        /*

        You can use the following on OS X:
        
        [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.scrollTo(%f, %f)", xPos, yPos]];
        */
        
       // adWebView.mainFrame.
        
       textChanges++
       let newTextLength = textView.string.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
       let changeInTextLength = newTextLength - textLength
       textLength = newTextLength
        
       println("text changed: \(textChanges)")
        
        if changeInTextLength > 20 {
            
            println("-- refreshing, changeInTextLength: \(changeInTextLength)")
            updateUI(refresh: true)
        }
        else if textChanges % 20 == 0 {
            
            println("-- refreshing, textChanges: \(textChanges)")
            updateUI(refresh: true)
        }
    }
    
    
}

