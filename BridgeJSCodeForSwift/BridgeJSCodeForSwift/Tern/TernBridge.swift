//
//  TernBridge.swift
//  BridgeJSCodeForSwift
//
//  Created by anthann on 2019/3/22.
//  Copyright © 2019 anthann. All rights reserved.
//

import Foundation
import JavaScriptCore

@objc protocol TernExportProtocol: JSExport {
    func getFile(_ filename: String) -> String
    func callback(_ error: Any?, _ response: Any?)
}

@objc class TernBridge: NSObject {
    public var fileContents: [String: String] = [String: String]()
    public weak var delegate: TernJSProtocol?
    
    @discardableResult
    static func registerInto(jsContext: JSContext, forKeyedSubscript: String = "TernBridge") -> TernBridge {
        // Load source files
        let bundle = Bundle.main
        let sources = ["polyfill", "acorn", "acorn-loose", "walk", "signal", "tern", "def", "comment", "infer", "modules", "es_modules", "requirejs", "doc_comment", "complete_strings", "commonjs"]
        for source in sources {
            if let url = bundle.url(forResource: source, withExtension: "js", subdirectory: "tern") {
                jsContext.evaluateScript(try! String(contentsOf: url), withSourceURL: url)
            } else {
                fatalError()
            }
        }
        // Initialize Tern.Server
        let instance = TernBridge()
        jsContext.setObject(instance,
                            forKeyedSubscript: forKeyedSubscript as NSString)
        jsContext.evaluateScript(
            "function __callback__(err, response) { return TernBridge.callback(err, response) }" +
            "let ternServer = new tern.Server({"       +
            "    getFile: TernBridge.getFile,"         +
            "    async: true,"                         +
            "    plugins: {commonjs: true},"                         +
            "});"                                      +
            "ternServer.requestFileUpdate = function(filename, content) {"                                            +
            "    this.request({files: [{type: 'full', name: filename, text: content}]}, __callback__)" +
            "};"
            
        )
        return instance
    }
    
    public func onTextChange(context: JSContext, _ text: String, filename: String) {
        self.fileContents[filename] = text
        context.evaluateScript("ternServer.requestFileUpdate('\(filename)', `\(text)`);")
    }
    
    public func requestForHint(context: JSContext, filename: String, offset: Int) {
        context.evaluateScript("""
            ternServer.request({query: {type: "completions", file: '\(filename)', end: \(offset)}}, __callback__)
            """)
    }
    
    public func addFile(context: JSContext, name: String, content: String) {
        context.evaluateScript("""
            ternServer.addFile(`\(name)`, `\(content)`);
            """)
    }
    
    public func deleteFile(context: JSContext, name: String) {
        context.evaluateScript("""
            ternServer.delFile(`\(name)`);
            """)
    }
    
    public func acornParse(context: JSContext, code: String, loose: Bool) -> String? {
        let script: String
        if loose {
            script = "JSON.stringify(acorn.loose.parse(`\(code)`))"
        } else {
            script = "JSON.stringify(acorn.parse(`\(code)`))"
        }
        let result = context.evaluateScript(script)
        if let jsonStr = result?.toString() {
            return jsonStr
        } else {
            return nil
        }
    }
}

extension TernBridge: TernExportProtocol {
    func getFile(_ filename: String) -> String {
        print("getfile: \(filename)")
        if let content = fileContents[filename] {
            return content
        } else {
            return ""
        }
    }
    
    func callback(_ error: Any?, _ response: Any?) {
        if let err = error {
            guard err is NSNull else {
                print("err: \(err)")
                return
            }
        }
        if let dict = response as? NSDictionary, let array = dict["completions"] as? NSArray, let start = dict["start"] as? Int, let end = dict["end"] as? Int {
            var candidates = [String]()
            for item in array {
                if let str = item as? String {
                    candidates.append(str)
                }
            }
            let range = NSMakeRange(start, end - start)
            delegate?.completions(sender: self, candidates: candidates, range: range)
            print(dict)
        }
    }
}
