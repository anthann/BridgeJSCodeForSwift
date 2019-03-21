//
//  TernViewController.swift
//  BridgeJSCodeForSwift
//
//  Created by anthann on 2019/3/21.
//  Copyright © 2019 anthann. All rights reserved.
//

import UIKit

class TernViewController: UIViewController {
    lazy var ternJS = TernJS()
    lazy var textView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Tern"
        
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.delegate = self
        view.addSubview(textView)
        textView.snp.makeConstraints { (make) in
            make.left.equalTo(view.safeAreaLayoutGuide.snp.left)
            make.right.equalTo(view.safeAreaLayoutGuide.snp.right)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.snp.centerY)
        }
//        ternJS.addFile(name: "abc.js", content: "")
    }
}

extension TernViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
//        ternJS.onTextChange(textView.text)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "." {
            let content = textView.text + text
            ternJS.requestForHint(currentFileContent: content, filename: "abc.js", offset: content.count) { (err, response) in
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
//            ternJS.requestForHint(currentFileContent: content, filename: "abc.js", offset: content.count, codeCompleteBl)
        }
        return true
    }
}
