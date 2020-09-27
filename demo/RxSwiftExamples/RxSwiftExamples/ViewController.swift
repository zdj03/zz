//
//  ViewController.swift
//  RxSwift
//
//  Created by 周登杰 on 2019/10/27.
//  Copyright © 2019 zdj. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    lazy var dataSource = ["Simple validation"]


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "Rx Examples"
                
    }
}


extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExamplesCellID", for: indexPath) as? ExamplesCel else {
            let cell = ExamplesCel()
            cell.textLabel?.text = dataSource[indexPath.row]
            return cell
        }
        cell.textLabel?.text = dataSource[indexPath.row]
        return cell;
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

    }
}

