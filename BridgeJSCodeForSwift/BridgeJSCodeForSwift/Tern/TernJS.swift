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
    private let jsContext = JSContext()!
    private var fileContent: String = ""

    init() {
        jsContext.exceptionHandler = { (ctx: JSContext!, value: JSValue!) in
            print(value!.toString())
        }
        let window = JSValue(newObjectIn: jsContext)
        jsContext.setObject(window, forKeyedSubscript: "window" as NSString)
        TimerJS.registerInto(jsContext: jsContext)
//        let setTimeoutBlock: @convention(block) (JSValue, JSValue) -> () = { function, timeout in
//            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(timeout.toInt32())), execute: {
//                function.call(withArguments: [])
//            })
//        }
//        jsContext.setObject(setTimeoutBlock, forKeyedSubscript: "setTimeout" as NSString)
        
        // Load source files
        let bundle = Bundle.main
        let sources = ["polyfill", "acorn", "acorn-loose", "walk", "signal", "tern", "def", "comment", "infer"]
        for source in sources {
            if let url = bundle.url(forResource: source, withExtension: "js", subdirectory: "tern") {
                jsContext.evaluateScript(try! String(contentsOf: url), withSourceURL: url)
            } else {
                fatalError()
            }
        }
        
        let getFile: @convention(block) (String) -> String = { [weak self] filename in
            print("filename: \(filename)")
            guard let strongSelf = self else {
                return ""
            }
            return strongSelf.fileContent
        }
        jsContext.setObject(getFile, forKeyedSubscript: "_native_getfile" as NSString)
        
        jsContext.evaluateScript("""
        var ternServer = new tern.Server({
            getFile: _native_getfile,
            async: true,
        });
        """)
    }
    
    public func onTextChange(_ text: String, filename: String, offset: Int) {
        
    }
    
    public func requestForHint(currentFileContent: String, filename: String, offset: Int) {
        fileContent = currentFileContent
        addFile(name: filename, content: currentFileContent)
        let ternServer = jsContext.objectForKeyedSubscript("ternServer")
        jsContext.evaluateScript("""
            var __doc = {query: {type: "completions", file: \"\(filename)\", end: \(offset)}}
            """
            )
        guard let doc = jsContext.objectForKeyedSubscript("__doc") else {
            return
        }
        let callback: @convention(block) (Any?, Any?) -> () = { err, response in
            print("Response: \n")
            if let err = err {
                if err is NSNull {
                } else {
                    print("err: \(err)")
                }
            }
            if let dict = response as? NSDictionary {
                print(dict)
            }
        }
        jsContext.setObject(callback, forKeyedSubscript: "__response_call_back" as NSString)
        guard let callbackObj = jsContext.objectForKeyedSubscript("__response_call_back") else {
            return
        }
        ternServer?.invokeMethod("request", withArguments: [doc, callbackObj])
        
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
    
    public func deleteFile(name: String) {
        guard let ternServer = jsContext.objectForKeyedSubscript("ternServer") else {
            return
        }
        ternServer.invokeMethod("delFile", withArguments: [name])
    }

}

let timerJSSharedInstance = TimerJS()

@objc protocol TimerJSExport : JSExport {
    
    func setTimeout(_ callback : JSValue,_ ms : Double) -> String
    
    func clearTimeout(_ identifier: String)
    
    func setInterval(_ callback : JSValue,_ ms : Double) -> String
    
}

// Custom class must inherit from `NSObject`
@objc class TimerJS: NSObject, TimerJSExport {
    var timers = [String: Timer]()
    
    static func registerInto(jsContext: JSContext, forKeyedSubscript: String = "timerJS") {
        jsContext.setObject(timerJSSharedInstance,
                            forKeyedSubscript: forKeyedSubscript as (NSCopying & NSObjectProtocol))
        jsContext.evaluateScript(
            "function setTimeout(callback, ms) {" +
                "    return timerJS.setTimeout(callback, ms)" +
                "}" +
                "function clearTimeout(indentifier) {" +
                "    timerJS.clearTimeout(indentifier)" +
                "}" +
                "function setInterval(callback, ms) {" +
                "    return timerJS.setInterval(callback, ms)" +
            "}"
        )
    }
    
    func clearTimeout(_ identifier: String) {
        let timer = timers.removeValue(forKey: identifier)
        
        timer?.invalidate()
    }
    
    
    func setInterval(_ callback: JSValue,_ ms: Double) -> String {
        return createTimer(callback: callback, ms: ms, repeats: true)
    }
    
    func setTimeout(_ callback: JSValue, _ ms: Double) -> String {
        return createTimer(callback: callback, ms: ms , repeats: false)
    }
    
    func createTimer(callback: JSValue, ms: Double, repeats : Bool) -> String {
        let timeInterval  = ms/1000.0
        
        let uuid = NSUUID().uuidString
        
        // make sure that we are queueing it all in the same executable queue...
        // JS calls are getting lost if the queue is not specified... that's what we believe... ;)
        DispatchQueue.main.async(execute: {
            let timer = Timer.scheduledTimer(timeInterval: timeInterval,
                                             target: self,
                                             selector: #selector(self.callJsCallback),
                                             userInfo: callback,
                                             repeats: repeats)
            self.timers[uuid] = timer
        })
        
        
        return uuid
    }
    
    @objc func callJsCallback(_ timer: Timer) {
        let callback = (timer.userInfo as! JSValue)
        
        callback.call(withArguments: nil)
    }
}
