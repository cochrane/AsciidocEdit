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
    
//MARK: appDelegate

    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        
        
        
        let nc = NSNotificationCenter()
        nc.addObserver(self, selector: "processNotification", name: nil, object: nil)

        let frame = NSMakeRect(0.0, 0.0, 1200.0, 700.0)
        window.setFrame(frame, display: true)
        window.backgroundColor = NSColor.blackColor()
        window.title = "AsciiHelper"
        
        let url = recallValueOfKey("documentURL")
        if let documentURL = url {
           println("DOCUMENT URL: \(documentURL)")
           synchronizePaths(documentURL)
           println("DOCUMENT PATH: \(documentPath)")
           textView.string = readStringFromPath(documentPath!)
           updateUI(refresh: true)
            messageLabel.stringValue = "Opened file: \(documentPath!)"
            messageLabel.needsDisplay = true
            
        } else {
            
            textView.string =  "Couldn't find the last file you opened."
            messageLabel.stringValue = "Couldn't find the last file you opened."
            messageLabel.needsDisplay = true
        }
        
        
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

    
        
    }

    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }
    
//MARK: Notifications
    
    func processNotification(notification: NSNotification) {
        
        println("Notification: \(notification)")
        
    }   


//MARK: IBActions
    
    @IBAction func newFileAction(sender: AnyObject) {

        if let docDir = documentsDirectory() {
         let filePath = docDir + "/tmp-89613.ad"
            println("filePath: \(filePath)")
            "New file".writeToFile(filePath, atomically: false, encoding: NSUTF8StringEncoding, error: nil);
            let url = "file:///"+filePath
            synchronizePaths(url)
            
            memorizeKeyValuePair("documentURL", url)
            
            documentText = readStringFromPath(documentPath!)
            textView.string = documentText
            
            updateUI(refresh: true)
            
            messageLabel.stringValue = "New file: \(filePath)"
            messageLabel.needsDisplay = true

        } else {
            println("Couldn't form docuumetns_idr")
        }

        
    }
    
    
    @IBAction func closeFileAction(sender: AnyObject) {
    }
    
    @IBAction func moveFileAction(sender: AnyObject) {
        
        

        // NSURL(string: htmlDocumentURL)
        
        
        let newDocumentURLString = baseName(documentURL!) + "2.ad"
        let newDocumentURL = NSURL(string: newDocumentURLString)
        let oldDocumentURL = NSURL(string: documentURL!)
        
        
        // func moveItemAtURL(srcURL: NSURL!, toURL dstURL: NSURL!, error: NSErrorPointer) -> Bool
        // NSFileManager.moveItemAtURL(oldDocumentURL, toURL: newDocumentURL, error :nil)
        
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
                
                
                synchronizePaths(url)
                
                println("\ndocumentURL: \(documentURL!)")
                println("\nhtmlDocumentURL: \(htmlDocumentURL!)")
                
                memorizeKeyValuePair("documentURL", url)
                recallValueOfKey("documentURL")
                
                documentText = readStringFromPath(documentPath!)
                textView.string = documentText
                
                updateUI(refresh: false)
                
                // http://lapcatsoftware.com/blog/2006/11/19/the-webview-reloaded/
              }
            }
        }
        
        messageLabel.stringValue = "Opened file: \(documentPath!)"
        messageLabel.needsDisplay = true

        
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
    
    
//MARK: Helpers
    
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
        // messageLabel.stringValue = "File: \(documentPath).    Word count: \(documentText.countWords())"
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
        
        /*
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
      */
    }
    
    
}

