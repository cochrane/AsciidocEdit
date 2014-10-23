// Playground - noun: a place where people can play

import Cocoa
import Foundation




extension String {
    
func match( str: String) -> [String] {
    
    var err: NSError?
    let regex = NSRegularExpression(pattern: self, options: NSRegularExpressionOptions(0), error: &err)
    if err != nil {
        return [String]()
    }
    let nsstr = str as NSString
    let all = NSRange(location: 0, length: nsstr.length)
    var matches = [String]()
    regex!.enumerateMatchesInString(str, options: nil, range: all) {
        (result: NSTextCheckingResult!, _, _) in matches.append(nsstr.substringWithRange(result.range))
    }
    return matches
}

}


let str = "axx\n bxx.ad\n  dfkdj  cxx.ad/n"

let pattern = ".ad"

let m2 = pattern.match(str).count












