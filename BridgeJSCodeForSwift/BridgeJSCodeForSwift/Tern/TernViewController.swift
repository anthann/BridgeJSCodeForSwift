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
    lazy var tableView = UITableView()
    var candidates: [String] = [String]()
    var range: NSRange?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Tern"
        
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.delegate = self
        view.addSubview(textView)
        textView.snp.makeConstraints { (make) in
            make.left.equalTo(view.safeAreaLayoutGuide.snp.left)
            make.right.equalTo(view.safeAreaLayoutGuide.snp.right)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.snp.centerY).offset(100)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.equalTo(view.safeAreaLayoutGuide.snp.left)
            make.right.equalTo(view.safeAreaLayoutGuide.snp.right)
            make.top.equalTo(textView.snp.bottom).offset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        ternJS.delegate = self
        ternJS.addFile(name: "bb.js", content: "let a = 123; module.exports = {a}")
    }
}

extension TernViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        self.range = nil
        candidates.removeAll()
        tableView.reloadData()
        guard let oldText = textView.text else {
            return true
        }
        let newText = (oldText as NSString).replacingCharacters(in: range, with: text)
        ternJS.onTextChange(newText, filename: "abc.js")
        ternJS.requestForHint(filename: "abc.js", offset: range.location + 1)
        return true
    }
}

extension TernViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return candidates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = candidates[indexPath.row]
        return cell
    }
}

extension TernViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = candidates[indexPath.row]
        if let originText = textView.text, let range = self.range {
            textView.text = (originText as NSString).replacingCharacters(in: range, with: item)
        }
        tableView.deselectRow(at: indexPath, animated: true)
        self.range = nil
        self.candidates.removeAll()
    }
}

extension TernViewController: TernJSProtocol {
    func completions(sender: TernBridge, candidates: [String], range: NSRange) {
        if !candidates.isEmpty {
            self.candidates.append(contentsOf: candidates)
            self.tableView.reloadData()
            self.range = range
        }
    }
}
