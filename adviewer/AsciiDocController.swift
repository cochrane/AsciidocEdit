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
    
    @IBOutlet weak var currentDirectoryTF: NSTextField!
    
    @IBOutlet weak var remoteNotebookTF: NSTextField!
    
    
    @IBOutlet weak var urlTextField: NSTextField!
    
    
    var documentPath: String?
    var documentOK = false
    var useLaTeXMode = false
    
    var foo: NSCursor?
    
    var documentText: String = ""
    var textChanges: Int = 0
    var textLength = 0
    var hasIncludes = false
    
    var userDictionary = [:] as [String:String]
    
    var manuscript = Manuscript()
    var metadata : Metadata?
   
   

    
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
    
    
    func getDocumentPath() -> String {
        
        if let documentURL = recallValueOfKey("documentURL") {
            return pathFromURL(documentURL)
        } else {
            return ""
        }
     }
    
    func setupDocumentPath(path: String) -> Bool {
        
        // documentPath = "/Users/carlson/Desktop/notebook/note.ad"
        // let url = Optional("file:///" + documentPath!)
        
        
        // documentPath = getDocumentPath()
        if path == "" {return false}
        if !fileExistsAtPath(path) { return false }
        if isDirectory(path) {return false }
        let ext = extName(path)
        if ext == "" { return false }
        if !contains(["ad", "adoc"], ext) {
            return false
        }
        return true
    }
    
    func memorizeKey(key: String) -> Bool {
    
      if userDictionary[key] == "" {
        
        return false
        
      } else {
        println("KEY: \(key)")
        memorizeKeyValuePair(key, userDictionary[key]!)
        return true
        }
        
    }
    
    
    func manageDictionary() -> Bool {
        
        documentPath = getDocumentPath()
        
        let dictPath = dictionaryPath(documentPath!)
        userDictionary = readDictionary(dictPath)
        printDictionary(userDictionary)
        
        var toolchainLoaded = true
        toolchainLoaded = memorizeKey("ASCIIDOCTOR")
        toolchainLoaded = memorizeKey("ASCIIDOCTOR-PDF")
        toolchainLoaded = memorizeKey("ASCIIDOCTOR-EPUB")
        toolchainLoaded = memorizeKey("GET_NOTEBOOK")
        toolchainLoaded = memorizeKey("PREPROCESS_TEX")
 
        return toolchainLoaded
        
    }
    
    func setupDocument() -> Bool {
        
      
        documentPath = getDocumentPath()
        
        documentOK = setupDocumentPath(documentPath!)
        
        if documentOK == false {
            textView.string = "Could not find \(documentPath!)"
            messageLabel.stringValue = "Couldn't find the last file you opened."
            messageLabel.needsDisplay = true
            return false
        }
        
       
        
        textView.string = readStringFromFile(documentPath!)
        useLaTeXMode = setLatexMode(textView.string! )
        setLatexMenuState()
        setHasIncludes()
        updateDocument(documentPath!)
        updateUI(refresh: true)
        
        manuscript = Manuscript()
        putMessage()
        
        
        return true
    }
    
    func setupWebview() {
        
        
        adWebView.UIDelegate = self
        adWebView.frameLoadDelegate = self
        adWebView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 6_1_4 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10B350 Safari/8536.25"
        adWebView.applicationNameForUserAgent = "Safari"
        
        let htmlDocumentURL = htmlURL(documentPath!)
        adWebView.mainFrame.loadRequest(NSURLRequest(URL: NSURL(string: htmlDocumentURL)!))
        
    }
    
    
    func setup() {
        
        setupWindow()
        setupTextView()
        setupNotifications()
        manageDictionary()
        if setupDocument() { setupWebview() }
        
        updateUI()
        
        var directory = directoryOfPath(documentPath!)
        
        //metadata = Metadata( path: directory + "/metadata.txt")
        //metadata!.print()

    }
    
    func updateUI() {
        
        currentDirectoryTF.stringValue = shortPath(directoryOfPath(documentPath!))
        
        if let id = userDictionary["remote_notebook"] {
            remoteNotebookTF.stringValue = "Remote notebook: \(id)"
        } else {
            remoteNotebookTF.stringValue = "Remote notebook: none"
        }
        
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
                
                    
                    documentPath = pathFromURL(url!)
                    
                    documentOK = setupDocumentPath(documentPath!)
                    
                    if !documentOK {
                        
                        let message = "You tried to open something you shouldn't -- try again."
                        putMessage(message: message)
                        return
                    }
                    
                    
                    let url = documentURL(documentPath!)
                    
                    // Add document to recent files menu
                    //println("\nAdd to recent documents, url = \(url)\n")
                    //let nsurl = NSURL(string: url)
                    //println("\nAdd to recent documents, nsurl = \(nsurl)\n")
                    //NSDocumentController.sharedDocumentController().noteNewRecentDocumentURL(nsurl!)
                    
                    // NSDocumentController.sharedDocumentController()
                    
                    //.allowedFileTypes = ["ad", "adoc", "asciidoc"]
                    
                    memorizeKeyValuePair("documentURL", url)
                    recallValueOfKey("documentURL")
                    
                    documentText = readStringFromFile(documentPath!)
                    useLaTeXMode = setLatexMode(documentText)
                    textView.string = documentText
                    
                    setHasIncludes()
                    
                    let dictPath = dictionaryPath(documentPath!)
                    userDictionary = readDictionary(dictPath)
                    printDictionary(userDictionary)
                    
        
                    updateDocument(documentPath!)
                    updateUI(refresh: true)
                    
                    // http://lapcatsoftware.com/blog/2006/11/19/the-webview-reloaded/
                }
            }
        }
        
        updateUI()
        putMessage()
        
    }
    
    @IBAction func saveFileAction(sender: AnyObject) {
        
        if let currentDocumentPath = documentPath {
            
            useLaTeXMode = setLatexMode(documentText)
            setLatexMenuState()
            updateDocument(currentDocumentPath)
            updateUI(refresh: true)
            
        }
        
        else {
        
            putMessage(message: "Error")
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
        
        let cmd = recallValueOfKey("ASCIIDOCTOR")
        
        if cmd != "" {
        
            let raw_version = executeCommand(cmd!, ["-V"], verbose: true)
            let part = raw_version.componentsSeparatedByString("\n")
            let version = part[0]
            
            
            messageLabel.stringValue = version
            messageLabel.needsDisplay = true
            
        } else {
            
            putMessage(message: "ERROR: could not fnd Asciidoctor")
        }
        
        
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
    
    /***
    
    You should access the DOM using the Objective-C DOM API and insert the appropriate <link> or <style> element into the DOM.
    
    
    DOMDocument* domDocument=[webView mainFrameDocument];
    DOMElement* styleElement=[domDocument createElement:@"style"];
    [styleElement setAttribute:@"type" value:@"text/css"];
    DOMText* cssText=[domDocument createTextNode:@"body{font-weight:bold;}"];
    [styleElement appendChild:cssText];
    DOMElement* headElement=(DOMElement*)[[domDocument getElementsByTagName:@"head"] item:0];
    [headElement appendChild:styleElement];
    
    
    **/
    
    
    // var webDoc = adWebView.mainFrameDocument
    // var archive_message = adWebView.stringByEvaluatingJavaScriptFromString("document.getElementsByTagName('p')[1].innerHTML")
    // println("archive_message = \(archive_message)")

    
    func askServerToArchiveNotebook() -> Bool {
    
        let url = urlTextField.stringValue
        // dWebView.mainFrame.loadRequest(NSURLRequest(URL: NSURL(string: url)!))
        
        if url.contains("notebook") {
            
            manuscript.parseURL(url)
            
            let archiveURL = manuscript.archiveURL!
            
            println("!!! ARCHIVE URL: \(archiveURL)")
            
            adWebView.mainFrame.loadRequest(NSURLRequest(URL: NSURL(string: archiveURL)!))
            adWebView.mainFrameURL = archiveURL
            adWebView.needsDisplay = true
            
            let dictPath = dictionaryPath(documentPath!)
            userDictionary = readDictionary(dictPath)
            printDictionary(userDictionary)
            
            let remote_id = manuscript.notebook_id!
            let user_id = userDictionary["remote_notebook"]
            
            if remote_id == user_id {
                
                putMessage(message: "remote notebook OK, procedding ...")
                return true
                
            } else {
                
                let message =  "Sorry, you would overwrite an existing notebook (\(remote_id):\(user_id))"
                putMessage(message: message)
                return false
            }
            
           
        
        } else {
            
            return false
        }
        
    }
    
        
    func fetchAndUpdate() {
        
        let directory = directoryOfPath(documentPath!)
        println("MANUSCRIPT NOTEBOOK ID: \(manuscript.notebook_id)")
        println("DIRECTORY: \(directory)")
        let message = fetchNotebook(manuscript.notebook_id!, directory)
        putMessage(message: message)
        
       
    }
    
    func updateAfterFetch() {
    
        let directory = directoryOfPath(documentPath!)
        
        documentPath = join([directory, "manifest.ad"], separator: "/")
        documentText = readStringFromFile(documentPath!)
        useLaTeXMode = true    /// setLatexMode(documentText)
        textView.string = documentText
        
        refreshHTML(documentPath!, htmlPath(documentPath!), useLaTexMode: true)
        updateUI(refresh: true)
        
        let url = documentURL(documentPath!)
        memorizeKeyValuePair("documentURL", url)
       
    }
    
    @IBAction func fetchNoteshareArchiveAction(sender: AnyObject) {
        
        println("URL = \(urlTextField.stringValue)")
        
        let proceed = askServerToArchiveNotebook()
        if proceed == true {
            fetchAndUpdate()
            updateAfterFetch()
        }
        
    }
    
    
    @IBAction func processManuscriptAction(sender: AnyObject) {
        
        println("Document Path: \(documentPath)")
        
        
        let adFiles = generateIncludeList(documentPath!)
        
        
        println("---------------------------")
        
        for file in adFiles {
            
            println("include::\(file)[]")
        }
        
        println("---------------------------")
        
        manuscript = Manuscript()
        manuscript.filePath = documentPath!
             manuscript.load()
        
    }
    
    
    @IBAction func gitUpdateAction(sender: AnyObject) {
        
        let gitURL = manuscript.gitURL()
        
        let currentDirectory = directoryPath(documentPath!)
        
        let cmd = currentDirectory + "/git_script"
        
        executeCommand(cmd, ["add", "."], verbose: true)

        
    }
    
    
    @IBAction func gitPullAction(sender: AnyObject) {
        
        let gitURL = manuscript.gitURL()
        
        let currentDirectory = directoryPath(documentPath!)
        
        let cmd = currentDirectory + "/git_script"
        
        executeCommand(cmd, ["pull", gitURL], verbose: true)
        
       
    }
    
    
    @IBAction func gitPushAction(sender: AnyObject) {
        
        let gitURL = manuscript.gitURL()
        
        let currentDirectory = directoryPath(documentPath!)
        
        let cmd = currentDirectory + "/git_script"
        
        executeCommand(cmd, ["push", gitURL], verbose: true)
        
        
    }
    
    
    
    @IBAction func cleanHTMLAction(sender: AnyObject) {
        
        cleanHTML(directoryPath(documentPath!))
        
    }
    
    //MARK: Web
    
    
    @IBAction func gotoURL_Action(sender: AnyObject) {
        
        println("URL = \(urlTextField.stringValue)")
        
        var url = urlTextField.stringValue
        if url.contains("/notebook/") {
            
            url = url.stringByReplacingOccurrencesOfString("/notebook",withString: "/notebook2")
            urlTextField.stringValue = url
            
        }
        adWebView.mainFrame.loadRequest(NSURLRequest(URL: NSURL(string: url)!))
        adWebView.mainFrameURL = url
        adWebView.needsDisplay = true
        
    }
    
    //MARK: Helpers
    
    func putMessage(message: String = "") {
        
        if message == "" {
          let word_count = documentText.countWords()
          let page_count = Int(trunc(Double(word_count)/305))
        
            messageLabel.stringValue = "\(shortPath(documentPath!,numberOfParts:1)): word count: \(word_count), about \(page_count) pages"
            
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
