//
//  controller.swift
//  adviewer
//
//  Created by James Carlson on 8/12/14.
//  Copyright (c) 2014 James Carlson. All rights reserved.
//

import Cocoa
import WebKit
// import Manifest

class AsciiDocController: NSObject, NSTextViewDelegate {
    
    
    @IBOutlet weak var window: NSWindow!
    
    
    
    @IBOutlet weak var scrollView: NSScrollView!
   
    @IBOutlet var textView: NSTextView!
    
    
    @IBOutlet weak var adWebView: WebView!
    
    @IBOutlet weak var messageLabel: NSTextField!
    
    
    @IBOutlet weak var latexMenuItem: NSMenuItem!
    
    
    var documentPath: String?
    var useLaTeXMode = false
    
    var foo: NSCursor?
    
    var documentText: String = ""
    var textChanges: Int = 0
    var textLength = 0
    var hasIncludes = false
    
    var manifest: Manifest?

    
    func setupWindow() {
        
        let frame = NSMakeRect(100.0, 400.0, 1200.0, 700.0)
        window.setFrame(frame, display: true)
        window.backgroundColor = NSColor.blackColor()
        window.title = "AsciidocEdit"
        
        
    }

    func setupTextView() {
        
        textView.font = NSFont(name: "Helvetica", size: 18.0)
        
        textView.automaticSpellingCorrectionEnabled = false
        textView.automaticDashSubstitutionEnabled = false
        textView.automaticQuoteSubstitutionEnabled = false
        
        textView.backgroundColor =  NSColor(SRGBRed: 0.9, green: 0.9, blue: 0.88, alpha: 1.0)
        textView.textColor = NSColor(SRGBRed: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        
        textView.delegate = self
        
    }
    
    func setupNotifications() {
        
        let nc = NSNotificationCenter()
        nc.addObserver(self, selector: "processNotification", name: nil, object: nil)
        
    }
    
    func setupDocument() {
        
        let url = recallValueOfKey("documentURL")
        

        //  documentPath = "/Users/carlson/Desktop/notebook/note.ad"
        // let url = Optional("file:///" + documentPath!)
        
       
    
        if let documentURL = url {
            
            
            documentPath = pathFromURL(documentURL)
            
            if fileExistsAtPath(documentPath!) {
                
                
                textView.string = readStringFromFile(documentPath!)
                
                
            } else {
                
                textView.string = "Could not find \(documentPath!)"
                
            }
            
            useLaTeXMode = setLatexMode(textView.string! )
            setLatexMenuState()

            
            setHasIncludes()
            
            updateUI(refresh: true)
            
            putMessage()
            
        } else {
            
            textView.string =  "Couldn't find the last file you opened."
            messageLabel.stringValue = "Couldn't find the last file you opened."
            messageLabel.needsDisplay = true
        }
    }
    
    func setupWebview() {
        
        
        adWebView.UIDelegate = self
        adWebView.frameLoadDelegate = self
        
        let htmlDocumentURL = htmlURL(documentPath!)
        adWebView.mainFrame.loadRequest(NSURLRequest(URL: NSURL(string: htmlDocumentURL)!))
        
    }
    
    
    func setup() {
        
        setupWindow()
        setupTextView()
        setupNotifications()
        setupDocument()// complain: launch path not accessible
        setupWebview()

    }

    
    override func webView(sender: WebView!, didFinishLoadForFrame frame: WebFrame!) {
        
        keepPlace()
        
    }
    

    
    //MARK: Notifications
    
    func processNotification(notification: NSNotification) {
        
        println("Notification: \(notification)")
        
    }
    
    
    //MARK: IBActions
    
    
    func yonk(contents: String) {
        
        contents.writeToFile(documentPath!, atomically: false, encoding: NSUTF8StringEncoding, error: nil);
        
        
        let url = documentURL(documentPath!)
        
        memorizeKeyValuePair("documentURL", url)
        
        documentText = readStringFromFile(documentPath!)
        textView.string = documentText
        
        updateUI(refresh: true)
        
        putMessage()
        
    }
    
    
    @IBAction func newFileAction(sender: AnyObject) {
        
        
        let newFilePanel = NSSavePanel()
        
        newFilePanel.nameFieldLabel = "New file:"
        newFilePanel.allowedFileTypes = ["ad", "adoc", "asciidoc"]
        newFilePanel.prompt = "OK"
        newFilePanel.title = "Create new asciidoc file"
        
        
        func handler(result: Int) {
            
            
            if (result == NSFileHandlingPanelOKButton) {
                
                let url = newFilePanel.URL
                
                if let newURL = url!.absoluteString {
                    
                    documentPath = pathFromURL(newURL)
                    
                    yonk("New file.")
                }
                
            }
            
        }
        
        newFilePanel.beginWithCompletionHandler(handler)
    }

    
    
    @IBAction func closeFileAction(sender: AnyObject) {
        
    }
    
    
    @IBAction func copyToAction(sender: AnyObject) {
        
        
        let oldDocumentPath = documentPath
        let oldDocumentURL = documentURL(oldDocumentPath!)
        let fileContents = readStringFromFile(oldDocumentPath!)
        
        
        let newFilePanel = NSSavePanel()
        
        newFilePanel.nameFieldLabel = "Copy file to"
        newFilePanel.allowedFileTypes = ["ad", "adoc", "asciidoc"]
        // newFilePanel.prompt = "My Prompt"
        newFilePanel.title = "Copy \(documentPath)"
        
        
        func handler(result: Int) {
            
            
            if (result == NSFileHandlingPanelOKButton) {
                
                let url = newFilePanel.URL
                
                if let newURL = url!.absoluteString {
                    
                    documentPath = pathFromURL(newURL)
                    
                    yonk(fileContents)
                    
                }
                
            }
            
        }
        
        
        newFilePanel.beginWithCompletionHandler(handler)
        
    }
    
    
    @IBAction func moveFileAction(sender: AnyObject) {
        
        let oldDocumentPath = documentPath
        let oldDocumentURL = documentURL(oldDocumentPath!)
        let fileContents = readStringFromFile(oldDocumentPath!)
        
        
        let newFilePanel = NSSavePanel()
        
        newFilePanel.nameFieldLabel = "Move file to"
        newFilePanel.allowedFileTypes = ["ad", "adoc", "asciidoc"]
        // newFilePanel.prompt = "My Prompt"
        newFilePanel.title = "Move \(documentPath)"
        
        
        func handler(result: Int) {
            
            
            if (result == NSFileHandlingPanelOKButton) {
                
                let url = newFilePanel.URL
                
                if let newURL = url!.absoluteString {
                    
                    documentPath = pathFromURL(newURL)
                    
                    yonk(fileContents)
                    
                    let hPath = htmlPath(oldDocumentPath!)
                    
                    executeCommand("/bin/rm", [oldDocumentPath!, hPath], verbose: false)
                    
                    
                    
                    println("\nurl I chose = \(newURL)\n")
                }
                
            }
            
        }
        
        
        newFilePanel.beginWithCompletionHandler(handler)
        
        
    }
    
    
    
    @IBAction func openFileAction(sender: AnyObject) {
        
        
        let panel = NSOpenPanel()
        
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowedFileTypes = ["ad", "adoc", "asciidoc"]
        panel.allowsMultipleSelection = false // yes if more than one dir is allowed
        
        let clicked = panel.runModal()
        
        if (clicked == NSFileHandlingPanelOKButton) {
            
            for url in panel.URLs {
                
                if let url = url.absoluteString {
                    
                    println("-- URL: \(url)")
                    
                    documentPath = pathFromURL(url!)
                    
                    println("-- documentPath: \(documentPath)")
                    
                    // Add document to recent files menu
                    let url = documentURL(documentPath!)
                    println("\nAdd to recent documents, url = \(url)\n")
                    let nsurl = NSURL(string: url)
                    println("\nAdd to recent documents, nsurl = \(nsurl)\n")
                    NSDocumentController.sharedDocumentController().noteNewRecentDocumentURL(nsurl!)
                    
                    // NSDocumentController.sharedDocumentController()
                    
                    //.allowedFileTypes = ["ad", "adoc", "asciidoc"]
                    
                    memorizeKeyValuePair("documentURL", url)
                    recallValueOfKey("documentURL")
                    
                    documentText = readStringFromFile(documentPath!)
                    useLaTeXMode = setLatexMode(documentText)
                    textView.string = documentText
                    
                    
                    setHasIncludes()
                    
                    updateUI(refresh: false)
                    
                    // http://lapcatsoftware.com/blog/2006/11/19/the-webview-reloaded/
                }
            }
        }
        
        putMessage()
        
    }
    
    @IBAction func saveFileAction(sender: AnyObject) {
        
        if let currentDocumentPath = documentPath {
            
            useLaTeXMode = setLatexMode(documentText)
            setLatexMenuState()
            updateDocument(currentDocumentPath)
            updateUI(refresh: true)
            
        }
        
    }
    
    
    
    @IBAction func SaveAsPDFAction(sender: AnyObject) {
        
        saveAsPDF(documentPath!)
        
    }
    
    
    @IBAction func saveAsEPUB3Action(sender: AnyObject) {
        
        saveAsEPUB3(documentPath!)
    }
    
    
    func updateDocument(path: String) {
        
        documentText = textView.string!
        
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
        
        let raw_version = executeCommand(cmd, ["-V"], verbose: true)
        let part = raw_version.componentsSeparatedByString("\n")
        let version = part[0]
        
        
        messageLabel.stringValue = version
        messageLabel.needsDisplay = true
        
        
    }
    
    
    @IBAction func installAsciidoctorAction(sender: AnyObject) {
        
        installAsciidoctor()
    }
    
    
    
    @IBAction func keepPlaceAction(sender: AnyObject) {
        
        keepPlace()
    }
    
    
    
    func setLatexMenuState() {
        
        if useLaTeXMode == true {
            
            latexMenuItem.title = "√ Use LaTex Mode"
            
        } else {
            
            latexMenuItem.title = "Use Latex Mode"
        }

    }
    
    @IBAction func toggleLaTeXMode(sender: AnyObject) {
        
        useLaTeXMode = !useLaTeXMode
        
        setLatexMenuState()
        
        
    }
    
    //MARK: Project Menu
    
    
    @IBAction func fetchNoteshareArchiveAction(sender: AnyObject) {
        
       let directory = directoryOfPath(documentPath!)
        let message = fetchNotebook(documentPath!)
        putMessage(message: message)
        
        fetchNotebook("mathematics_notebook_2014_128")
        
    }
    
    
    @IBAction func processManifestAction(sender: AnyObject) {
        
        println("Document Path: \(documentPath)")
        
        
        let adFiles = generateIncludeList(documentPath!)
        
        
        println("---------------------------")
        
        for file in adFiles {
            
            println("include::\(file)[]")
        }
        
        println("---------------------------")
        
        manifest = Manifest(filePath: documentPath!)
        
        if manifest != nil {
            
            manifest!.load()
            
        }
        
    }
    
    
    @IBAction func gitUpdateAction(sender: AnyObject) {
        
        let gitURL = manifest!.gitURL()
        
        let currentDirectory = directoryPath(documentPath!)
        
        let cmd = currentDirectory + "/git_script"
        
        executeCommand(cmd, ["add", "."], verbose: true)

        
    }
    
    
    @IBAction func gitPullAction(sender: AnyObject) {
        
        let gitURL = manifest!.gitURL()
        
        let currentDirectory = directoryPath(documentPath!)
        
        let cmd = currentDirectory + "/git_script"
        
        executeCommand(cmd, ["pull", gitURL], verbose: true)
        
       
    }
    
    
    @IBAction func gitPushAction(sender: AnyObject) {
        
        let gitURL = manifest!.gitURL()
        
        let currentDirectory = directoryPath(documentPath!)
        
        let cmd = currentDirectory + "/git_script"
        
        executeCommand(cmd, ["push", gitURL], verbose: true)
        
        
    }
    
    
    
    @IBAction func cleanHTMLAction(sender: AnyObject) {
        
        cleanHTML(directoryPath(documentPath!))
        
    }
    
    //MARK: Helpers
    
    func putMessage(message: String = "") {
        
        if message == "" {
          let word_count = documentText.countWords()
          let page_count = Int(trunc(Double(word_count)/305))
        
          messageLabel.stringValue = "File: \(shortPath(documentPath!)).    Word count: \(word_count), about \(page_count) pages"
            
        }
        
        else {
            
             messageLabel.stringValue = message
        }
        
        messageLabel.needsDisplay = true
    
    }
    
    func updateUI(#refresh: Bool) {
        
        
        if refresh {
            
            if let currentDocumentPath = documentPath {
                
                updateDocument(currentDocumentPath)
                
            }
            
            if fileExistsAtPath(documentPath!) {
                
                refreshHTML(documentPath!, htmlPath(documentPath!), useLaTexMode: useLaTeXMode)
                
            }
            
        }
        
        let win = adWebView.windowScriptObject
        let location: AnyObject! = win.valueForKey("location")
        let href: AnyObject! = location.valueForKey("href");
        
        println("location: \(location)")
        println("href: \(href)")
        
        let hURL = htmlURL(documentPath!)
        adWebView.mainFrame.loadRequest(NSURLRequest(URL: NSURL(string: hURL)!))
        adWebView.mainFrameURL = hURL
        adWebView.needsDisplay = true
        
        putMessage()
        
        window.viewsNeedDisplay = true
        keepPlace()
        
    }
    
    
    
    func keepPlace() {
        
        adWebView.stringByEvaluatingJavaScriptFromString("keep_place()")
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
    
    func setHasIncludes() {
        
        
        if textView.string!.rangeOfString("include::") == nil {
            
            hasIncludes = false
            
        } else {
            
            hasIncludes = true
        }
    }
    
    
    ///////////////////
    
    // - (BOOL)application:(NSApplication *)theApplication openFile:(NSString
    //*)filename
    
    // http://www.cocoabuilder.com/archive/cocoa/54514-open-recent-menu-in-non-doc-app.html
    
    func application(sender: NSApplication!, openFile filename: String!) -> Bool {
        
        println("FOO::BAR")
        
        if fileExistsAtPath(filename){
            
            println("I AM IN application - openFile, found \(filename)")
            let url = "file:///"+filename
            
            documentText = readStringFromFile(filename)
            textView.string = documentText
            updateUI(refresh: true)
            putMessage()
            
            
            return true
            
        } else {
            
            println("I AM IN application - openFile, can't find \(filename)")
            
            return false
        }
    }
    
    
}
