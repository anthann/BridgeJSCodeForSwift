//
//  HighlightViewController.swift
//  BridgeJSCodeForSwift
//
//  Created by anthann on 2019/3/14.
//  Copyright © 2019 anthann. All rights reserved.
//

import UIKit

class HighlightViewController: UIViewController {
    lazy var highlightJS = HighlightJS()
    lazy var textView = UITextView()
    lazy var resultTextView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Highlight"
        
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

extension HighlightViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let html = highlightJS.highlight(textView.text)
        print(html)
        resultTextView.attributedText = highlightJS.style(code: html)
    }
}
