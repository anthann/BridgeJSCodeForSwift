//
//  ViewController.swift
//  BridgeJSCodeForSwift
//
//  Created by anthann on 2019/3/14.
//  Copyright © 2019 anthann. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    enum Items: Int {
        case prism = 0, highlight, max
        
        func  title() -> String {
            switch self {
            case .prism:
                return "Prism"
            case .highlight:
                return "Highlight"
            case .max:
                fatalError()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "选择一个JS框架"
        
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView()
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Items.max.rawValue
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = Items(rawValue: indexPath.item) else {
            fatalError()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = item.title()
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = Items(rawValue: indexPath.item) else {
            fatalError()
        }
        tableView.deselectRow(at: indexPath, animated: true)
        switch item {
        case .prism:
            let vc = PrismViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        case .highlight:
            let vc = HighlightViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
}
