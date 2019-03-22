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
}

@objc class TernBridge: NSObject {
    public var fileContents: [String: String] = [String: String]()
    
    @discardableResult
    static func registerInto(jsContext: JSContext, forKeyedSubscript: String = "TernBridge") -> TernBridge {
        let instance = TernBridge()
        jsContext.setObject(instance,
                            forKeyedSubscript: forKeyedSubscript as NSString)
        jsContext.evaluateScript(
            "function __native_getfile(name) {" +
                "console.log('123'); " +
            "    return TernBridge.getFile(name)" +
            "}" +
            "let ternServer = new tern.Server({"       +
            "    getFile: __native_getfile,"         +
            "    async: true,"                         +
            "});"                                      +
            "ternServer.requestFileUpdate = function(filename, content) {"                                            +
            "    this.request({files: [{type: 'full', name: filename, text: content}]}, (function(err, response){}))" +
            "};"
            
        )
        return instance
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
}
