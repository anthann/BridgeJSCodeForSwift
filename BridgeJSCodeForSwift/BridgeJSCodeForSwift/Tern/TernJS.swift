//
//  TernJS.swift
//  BridgeJSCodeForSwift
//
//  Created by anthann on 2019/3/21.
//  Copyright © 2019 anthann. All rights reserved.
//

import Foundation
import JavaScriptCore

struct TernCompletionObject {
    let name: String
    let origin: String?
    let isKeyword: Bool?
    let type: String?
}

protocol TernJSProtocol: AnyObject {
    func completions(sender: TernBridge, candidates: [TernCompletionObject], range: NSRange)
}

class TernJS {
    typealias CodeCompleteBlock = @convention(block) (Any?, Any?) -> ()
    private let jsContext = JSContext()!
    private weak var ternBridge: TernBridge?
    public weak var delegate: TernJSProtocol? {
        didSet {
            ternBridge?.delegate = delegate
        }
    }

    init() {
        // Shim
        jsContext.exceptionHandler = { (context, exception) in
            guard let excep = exception else {
                return
            }
            print(excep)
            context?.exception = excep
        }
        let window = JSValue(newObjectIn: jsContext)
        jsContext.setObject(window, forKeyedSubscript: "window" as NSString)
        TimerJS.registerInto(jsContext: jsContext)
        ConsoleJSBridge.registerInto(jsContext: jsContext)
    
        // Initialize Tern.Server
        self.ternBridge = TernBridge.registerInto(jsContext: jsContext)
    }
    
    /// 更新源文件
    ///
    /// - Parameters:
    ///   - text: 完整源文件内容
    ///   - filename: 文件名
    public func onTextChange(_ text: String, filename: String) {
        ternBridge?.onTextChange(context: jsContext, text, filename: filename)
    }
    
    /// 获取代码提示
    ///
    /// - Parameters:
    ///   - filename: 源文件名
    ///   - offset: 光标相对文件首的偏移
    ///   - codeCompleteBlock: 回调函数。
    public func requestForHint(filename: String, offset: Int) {
        ternBridge?.requestForHint(context: jsContext, filename: filename, offset: offset)
    }
    
    /// 向TernServer增加一个源文件
    ///
    /// - Parameters:
    ///   - name: 文件名
    ///   - content: 文件初始内容
    public func addFile(name: String, content: String) {
        ternBridge?.addFile(context: jsContext, name: name, content: content)
    }
    
    /// 删除源文件
    ///
    /// - Parameter name: 文件名
    public func deleteFile(name: String) {
        ternBridge?.deleteFile(context: jsContext, name: name)
    }

    /// 调用acorn.parse，生成AST树
    ///
    /// - Parameters:
    ///   - code: 代码
    ///   - loose: true for “acorn.loose.parse()”, else “arcor.parse()”
    /// - Returns: AST树，JSON String格式
    public func acornParse(code: String, loose: Bool) -> String?{
        return ternBridge?.acornParse(context: jsContext, code: code, loose: loose)
    }
}
