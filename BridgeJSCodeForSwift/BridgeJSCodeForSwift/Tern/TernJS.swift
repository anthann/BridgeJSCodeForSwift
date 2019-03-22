//
//  TernJS.swift
//  BridgeJSCodeForSwift
//
//  Created by anthann on 2019/3/21.
//  Copyright © 2019 anthann. All rights reserved.
//

import Foundation
import JavaScriptCore

class TernJS {
    typealias CodeCompleteBlock = @convention(block) (Any?, Any?) -> ()
    private let jsContext = JSContext()!
    private weak var ternBridge: TernBridge?

    init() {
        // Shim
        jsContext.exceptionHandler = { (context, exception) in
            guard let excep = exception else {
                return
            }
            print(excep)
            /*
             此处打印js异常错误，JSContext不会主动抛出js异常。
             常见异常：
             ReferenceError: Can't find variable:
             TypeError: undefined is not an object
             */
            context?.exception = excep
        }
        let window = JSValue(newObjectIn: jsContext)
        jsContext.setObject(window, forKeyedSubscript: "window" as NSString)
        TimerJS.registerInto(jsContext: jsContext)
        ConsoleJSBridge.registerInto(jsContext: jsContext)
        
        // Load source files
        let bundle = Bundle.main
        let sources = ["polyfill", "acorn", "acorn-loose", "walk", "signal", "tern", "def", "comment", "infer", "modules", "es_modules", "requirejs", "doc_comment", "complete_strings"]
        for source in sources {
            if let url = bundle.url(forResource: source, withExtension: "js", subdirectory: "tern") {
                jsContext.evaluateScript(try! String(contentsOf: url), withSourceURL: url)
            } else {
                fatalError()
            }
        }
        
        // Initialize Tern.Server
        self.ternBridge = TernBridge.registerInto(jsContext: jsContext)
    }
    
    
    /// 更新源文件
    ///
    /// - Parameters:
    ///   - text: 完整源文件内容
    ///   - filename: 文件名
    public func onTextChange(_ text: String, filename: String) {
        guard let ternServer = jsContext.objectForKeyedSubscript("ternServer") else {
            return
        }
        self.ternBridge?.fileContents[filename] = text
//        ternServer.invokeMethod("requestFileUpdate", withArguments: [filename, text])
        jsContext.evaluateScript("ternServer.requestFileUpdate('\(filename)', `\(text)`);")
    }
    
    /// 获取代码提示
    ///
    /// - Parameters:
    ///   - filename: 源文件名
    ///   - offset: 光标相对文件首的偏移
    ///   - codeCompleteBlock: 回调函数。
    public func requestForHint(filename: String, offset: Int, codeCompleteBlock: @escaping CodeCompleteBlock) {
//        let ternServer = jsContext.objectForKeyedSubscript("ternServer")
//        jsContext.evaluateScript("""
//            var __doc = {query: {type: "completions", file: \"\(filename)\", end: \(offset)}}
//            """
//            )
//        guard let doc = jsContext.objectForKeyedSubscript("__doc") else {
//            return
//        }
        jsContext.setObject(codeCompleteBlock, forKeyedSubscript: "__response_call_back" as NSString)
//        guard let callbackObj = jsContext.objectForKeyedSubscript("__response_call_back") else {
//            return
//        }
//        ternServer?.invokeMethod("request", withArguments: [doc, callbackObj])
        jsContext.evaluateScript("""
            ternServer.request({query: {type: "completions", file: '\(filename)', end: \(offset)}}, __response_call_back)
        """)
    }
    
    /// 向TernServer增加一个源文件
    ///
    /// - Parameters:
    ///   - name: 文件名
    ///   - content: 文件初始内容
    public func addFile(name: String, content: String) {
        guard let ternServer = jsContext.objectForKeyedSubscript("ternServer") else {
            return
        }
        ternServer.invokeMethod("addFile", withArguments: [name, content])
    }
    
    
    /// 删除源文件
    ///
    /// - Parameter name: 文件名
    public func deleteFile(name: String) {
        guard let ternServer = jsContext.objectForKeyedSubscript("ternServer") else {
            return
        }
        ternServer.invokeMethod("delFile", withArguments: [name])
    }

}
