//
//  ConsoleJSBridge.swift
//  BridgeJSCodeForSwift
//
//  Created by anthann on 2019/3/22.
//  Copyright © 2019 anthann. All rights reserved.
//

import Foundation
import JavaScriptCore

@objc protocol ConsoleJSExportProtocol : JSExport {
    func log(_ text: String)
}

@objc class ConsoleJSBridge: NSObject {
    @discardableResult
    static func registerInto(jsContext: JSContext, forKeyedSubscript: String = "console") -> ConsoleJSBridge {
        let instance = ConsoleJSBridge()
        
        jsContext.setObject(instance,
                            forKeyedSubscript: forKeyedSubscript as NSString)
        return instance
    }
}

extension ConsoleJSBridge: ConsoleJSExportProtocol {
    func log(_ text: String) {
        print("console.log: \(text)")
    }
}
