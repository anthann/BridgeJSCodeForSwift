//
//  HighlightJS.swift
//  BridgeJSCodeForSwift
//
//  Created by anthann on 2019/3/14.
//  Copyright © 2019 anthann. All rights reserved.
//

import Foundation
import JavaScriptCore

class HighlightJS {
    private let jsContext = JSContext()!
    public let highlightJSValue: JSValue
    
    init() {
        jsContext.exceptionHandler = { (ctx: JSContext!, value: JSValue!) in
            print(value!.toString())
        }
        let window = JSValue(newObjectIn: jsContext)
        jsContext.setObject(window, forKeyedSubscript: "window" as NSString)
        
        
        guard let hgUrl = Bundle.main.url(forResource: "highlight", withExtension: "js", subdirectory: "highlight/src") else {
            fatalError()
        }
        jsContext.evaluateScript(try! String(contentsOf: hgUrl), withSourceURL: hgUrl)
        
        guard let hljs = window?.objectForKeyedSubscript("hljs") else {
            fatalError()
        }
        highlightJSValue = hljs
        if let jsUrl = Bundle.main.url(forResource: "javascript", withExtension: "js", subdirectory: "highlight/src/languages") {
            let languageString = try! String(contentsOf: jsUrl)
            if let value = jsContext.evaluateScript("(\(languageString))") {
                hljs.invokeMethod("registerLanguage", withArguments: ["javascript", value])
            }
        }
    }
    
    public func highlight(_ text: String) -> String {
        guard let ret = highlightJSValue.invokeMethod("highlight", withArguments: ["javascript", text, true]) else {
            return text
        }
        guard let res = ret.objectForKeyedSubscript("value") else {
            return text
        }
        if let str = res.toString() {
            return str
        } else {
            return text
        }
    }
    
    public func style(code: String, theme: String = "xcode") -> NSAttributedString {
        guard let themeUrl = Bundle.main.url(forResource: theme, withExtension: "css", subdirectory: "highlight/src/styles") else {
            return NSAttributedString(string: code)
        }
        let styleString = try! String(contentsOf: themeUrl)
        let html = "<style>" + styleString + "</style><pre><code class=\"hljs\">" + code + "</code></pre>"
        let opt: [NSAttributedString.DocumentReadingOptionKey : Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        guard let data = html.data(using: .utf8) else {
            return NSAttributedString(string: code)
        }
        do {
            let attributedStr = try NSAttributedString(data: data, options: opt, documentAttributes: nil)
            return attributedStr
        } catch {
            return NSAttributedString(string: code)
        }
        
    }
}

