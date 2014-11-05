//
//  utilities.swift
//  adviewer
//
//  Created by James Carlson on 8/3/14.
//  Copyright (c) 2014 James Carlson. All rights reserved.
//

let DICTIONARY_FILE = "config"

import Foundation

class ManuscriptProcessor {


    let toolChain: Toolchain?
    let foo: String?
    
    
    //MARK: File helpers
    
    init(path: String) {
    
        self.toolChain = Toolchain(path: path)
        self.toolChain!.setup()
        self.foo = "Ho ho ho                                                                        a"
    }

    // Return path for temporary file
    func tempFile(path: String) -> String {
        
        let part = path.componentsSeparatedByString(".")
        return part[0]+"-temp."+part[1]
    }
    
    // MARK: Inspectors
    
    
    func hasLatex(path: String) -> Bool {
        
        let content = File.read(path)
        let displayTexRx = /"\\[.*\\]"
        if content.contains(":latex:") || (content =~ displayTexRx) {
            return true
        } else { return false }
    }
    
   
     //MARK: Injectors

    // Inject resource into temporary file copy
    func injectFromBundle(inputPath: String, outputPath: String, payloadName: String, payloadType: String) {
        
        
        // Get text from file and break it into lines
        let inputText = File.read(inputPath)
        let jsContent = bundleContent(payloadName, resourceType: payloadType)
        let lines = inputText.componentsSeparatedByString("\n")
        
        // Insert Javascript after header
        var output = ""
        var firstBlankLineFound = false
        for line in lines {
            
            output += line  + "\n"
            if line == "" && firstBlankLineFound == false {
                output += "\n"+jsContent+"\n\n"
                firstBlankLineFound = true
            }
        }
        
        // Write transformed text to temporary file
        output.writeToFile(outputPath, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
       
    }





    // Inject payload into temporary file copy
    func injectFromFile(inputPath: String, outputPath: String, payloadPath: String) {
        
        println("\nBEGIN: injectFromFile")
        
        // Get text from file and break it into lines
        let inputText = File.read(inputPath)
        let payload = File.read(payloadPath)
        let lines = inputText.componentsSeparatedByString("\n")
        
        // Insert Javascript after header
        var output = ""
        var firstBlankLineFound = false
        for line in lines {
            
            output += line  + "\n"
            if line == "" && firstBlankLineFound == false {
                println("  ... writing payload ...")
                output += "\n"+payload+"\n\n"
                firstBlankLineFound = true
            }
        }
        
        // Write transformed text to temporary file
        
        println("\n-----------------\n\(output)\n------------\n")
        output.writeToFile(outputPath, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
        
        
        println("END: injectFromFile\n")
        
    }



    // Retrieve content of file in bundle
    func bundleContent(fileName: String, resourceType: String) -> String {
        

        let bundlePath = NSBundle.mainBundle().pathForResource(fileName, ofType: resourceType)
        let content = File.read(bundlePath!)
        return content

    }

    
    func injectMacros(path: String, _ m: Manuscript) {
        var macro_path = m.macro_path()
        if File.exists(macro_path) {
            File.catenate([m.macro_path(), path], path)
        } else {
            macro_path = File.file_in_parent(m.macro_path())
            if File.exists(macro_path) {
                File.catenate([macro_path, path], path)
            }
        }
    }
    
    func injectJavascript(path: String, _ m: Manuscript){
        var javascript_path = m.root + "/script.js"
        if  File.exists(javascript_path) { File.catenate([javascript_path, path], path) }
        else {
            javascript_path = File.file_in_parent(javascript_path)
            if  File.exists(javascript_path) {
                File.catenate([javascript_path, path], path)
            }
        }
    }
    
    
    func injectCSS(path: String, _ m: Manuscript) {
        var style_path = m.root + "/style.css"
        if  File.exists(style_path) {
            File.catenate([style_path, path], path)
        } else {
            style_path = File.file_in_parent(style_path)
            if  File.exists(style_path) {
                File.catenate([style_path, path], path)
            }
        }
    }
    
    //MARK: Processors
    
    func preprocessTex(path: String) {
        var content = ""
        if toolChain!.run("PREPROCESS_TEX", [path, path]).0 {
            content = File.read(path)
            content = ":stem: latexmath\n\n" + content
        } else {
            content = File.read(path)
        }
        File.write(content, path)
        File.write(content, "/Users/carlson/Desktop/preprocessed.text")
    }

    // (1) Inject "synchonize.js" after first non-blank line of
    // the file at asciidocPath and write it to a temporary
    // copy. (2) Apply asciidoctor to the temporary file.
    // (3) Remove the temporary files.
    func refreshHTML(asciidocPath: String, htmlPath: String, manuscript:  Manuscript!) {
        
        let tmp = tempFile(asciidocPath)
        let tempHTMLPath = tempFile(htmlPath)
        let innerUseLatexMode = hasLatex(asciidocPath)
        
        // Inject javascript code to keep rendered text in place //
        injectFromBundle(asciidocPath, outputPath: tmp, payloadName: "synchronize", payloadType: "js")
        
        // Insert macros, javascript, css, and preprocess
        if  true {
        // if  innerUseLatexMode {
          preprocessTex(tmp)
          injectMacros(tmp, manuscript)
        }
        // injectJavascript(tmp, manuscript)
        // injectCSS(tmp, manuscript)
        
       // Finally, run asciidoctor
        if toolChain!.run("ASCIIDOCTOR", ["-a", "stem=latexmath", tmp]).0 {
            Toolchain.executeCommand("/bin/cp", [tmp, "/Users/carlson/Desktop/out.html"])
            Toolchain.executeCommand("/bin/mv", [tempHTMLPath, htmlPath])
            Toolchain.executeCommand("/bin/rm", [tmp])
        }
   
    }


    
    //MARK: Exporters

    func saveAsPDF(filePath: String) {
        
            toolChain!.run("ASCIIDOCTOR_PDF", [filePath], verbose: true)
        
    }

    func saveAsEPUB3(filePath: String) {
            
            toolChain!.run("ASCIIDOCTOR_EPUB", [filePath])
        
    }
    
    //MARK: Noteshare

    func fetchNotebookFromURL(url: String) {
            
            toolChain!.run("GET_NOTEBOOK", [url])
        
    }



    func fetchNotebook(notebook_url: String, directory: String) -> String {
      

            let output = toolChain!.run("GET_NOTEBOOK", [notebook_url, directory], verbose: true).1
        
        
            let pattern = ".ad"
            let number_of_ad_files = pattern.match(output).count - 3
            return "Fetched \(number_of_ad_files) files from " + notebook_url
    
      
    }


    
    //MARK: Housekeeping

    func cleanHTML(directoryPath: String) {
        
        
        println("directoryPath = \(directoryPath)")
        
        let fileArray = File.ls(directoryPath)
        
        for file in fileArray {
            
            let path = directoryPath + "/" + file
            let ext = path.pathExtension
            
            if ext == "html" {
            
                println("REMOVED: \(path)")
                Toolchain.executeCommand("/bin/rm", [path])
                
        
            }
            
        }
        
        
    }
    
    
    //MARK: Manifest

    func generateIncludeList(masterFilePath: String)-> [String] {
        
        
        println("mASCIIterFilePath = \(masterFilePath)")
        
        let masterDirectoryPath = directoryPath(masterFilePath)
        
        let fileArray = File.ls(masterDirectoryPath)
        
        var array = [String]()
        
        for file in fileArray {
            
            let path = masterDirectoryPath + "/" + file
            let ext = path.pathExtension
            
            if ext == "ad" && path != masterFilePath {
                
               array.append(file)
                
            }
            
        }
        
        return array
        
    }

   


    //MARK: Extras



    func setLatexMode(content: String) -> Bool {
        
        
        let status = content.contains(":latex:")
        
        println("\nLATEX: \(status)")
        
        return status
        
    }

}

