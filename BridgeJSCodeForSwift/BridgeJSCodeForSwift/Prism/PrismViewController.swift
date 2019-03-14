//
//  PrismViewController.swift
//  BridgeJSCodeForSwift
//
//  Created by anthann on 2019/3/14.
//  Copyright © 2019 anthann. All rights reserved.
//

import UIKit
import SnapKit

class PrismViewController: UIViewController {
    lazy var prismJS = PrismJS()
    lazy var textView = UITextView()
    lazy var resultTextView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Prism"
        
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
        
        resultTextView.isEditable = false
        view.addSubview(resultTextView)
        resultTextView.snp.makeConstraints { (make) in
            make.left.right.equalTo(textView)
            make.top.equalTo(textView.snp.bottom)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
}

extension PrismViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let html = prismJS.highlight(textView.text)
        print(html)
        let attr = prismJS.style(code: html)
        resultTextView.attributedText = attr
    }
}
