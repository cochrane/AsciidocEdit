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



    // (1) Inject "synchonize.js" after first non-blank line of
    // the file at asciidocPath and write it to a temporary 
    // copy. (2) Apply asciidoctor to the temporary file.
    // (3) Remove the temporary files.
    // refreshHTML goes here
    func refreshHTML(asciidocPath: String, htmlPath: String, manuscript:  Manuscript!) {
        
        let tmp = tempFile(asciidocPath)
        var innerUseLatexMode = false
        var test_content = File.read(asciidocPath)
        if test_content.contains(":latex:") { innerUseLatexMode = true }
        
        injectFromBundle(asciidocPath, outputPath: tmp, payloadName: "synchronize", payloadType: "js")
        println("MACRO FILE: \(manuscript.macro_path())")

        if  innerUseLatexMode && File.exists(manuscript.macro_path()) {
            
              println("MACRO FILE (1) exists: \(manuscript.macro_path())")
            
              File.catenate([manuscript.macro_path(), tmp], tmp)
            
        } else {
            
            let macro_path = File.file_in_parent(manuscript.macro_path())
             println("MACRO FILE (2): \(macro_path)")
            if  innerUseLatexMode && File.exists(macro_path) {
                println("File exists at macro path (2)")
                File.catenate([macro_path, tmp], tmp)
            } else {
                println("File does NOT exist at macro path (2)")
            }
        }
        
        ////////
        
        var javascript_path = manuscript.root + "/script.js"
        
        if  File.exists(javascript_path) { File.catenate([javascript_path, tmp], tmp) }
        else {
            
            javascript_path = File.file_in_parent(javascript_path)
            println("MACRO FILE (2): \(javascript_path)")
            if  File.exists(javascript_path) {
                println("File exists at js path (2)")
                File.catenate([javascript_path, tmp], tmp)
            } else {
                println("File does NOT exist at js path (2)")
            }
        }
        
        //////////
        
        var style_path = manuscript.root + "/style.css"
        
        if  File.exists(style_path) {
             File.catenate([style_path, tmp], tmp)
        } else {        
            style_path = File.file_in_parent(style_path)
            println("MACRO FILE (2): \(style_path)")
            if  File.exists(style_path) {
                println("File exists at style path (2)")
                File.catenate([style_path, tmp], tmp)
            } else {
                println("File does NOT exist at style path (2)")
            }
        }
        
        
        
        
        /////////
        
        
        
        let tempHTMLPath = tempFile(htmlPath)
        
        if innerUseLatexMode {
            
            var content = ""
            
            
            if toolChain!.run("PREPROCESS_TEX", [tmp, tmp]) {
              content = File.read(tmp)
              content = ":stem: latexmath\n" + content
            } else {
               content = File.read(tmp)
            }
            File.write(content, tmp)
            
            
        }
        
     
        if   toolChain!.run("ASCIIDOCTOR", [tmp]) {
            Toolchain.executeCommand("/bin/mv", [tempHTMLPath, htmlPath])
            Toolchain.executeCommand("/bin/rm", [tmp])
        }
        
    }



    func saveAsPDF(filePath: String) {
        
            toolChain!.run("ASCIIDOCTOR_PDF", [filePath], verbose: true)
        
    }

    func saveAsEPUB3(filePath: String) {
            
            toolChain!.run("ASCIIDOCTOR_EPUB", [filePath])
        
    }

    func fetchNotebookFromURL(url: String) {
            
            toolChain!.run("GET_NOTEBOOK", [url])
        
    }



    func fetchNotebook(notebook_url: String, directory: String) -> String {
      

            toolChain!.run("GET_NOTEBOOK", [notebook_url, directory], verbose: true)
        
        /**
            let pattern = ".ad"
            let number_of_ad_files = pattern.match(output).count - 3
            return "Fetched \(number_of_ad_files) files from " + notebook_url
         **/
        
        return "***"
      
    }



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

    func generateIncludeList(masterFilePath: String)-> [String] {
        
        
        println("masterFilePath = \(masterFilePath)")
        
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

