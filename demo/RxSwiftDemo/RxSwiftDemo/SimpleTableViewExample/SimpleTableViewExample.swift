//
//  SimpleTableViewExample.swift
//  RxSwiftExamples
//
//  Created by 周登杰 on 2019/10/28.
//  Copyright © 2019 zdj. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SimpleTableViewExample: ViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        // MARK: - 产生只有唯一元素的一个可观察序列
        let items = Observable.just((0..<20).map{ "\($0)" })
        
        items
            .bind(to: tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)){
                row, element, cell in
                cell.textLabel?.text = "\(element) @ row \(row)"
        }
        .disposed(by: disposeBag)
        
        tableView.rx
            .modelSelected(String.self)
            .subscribe(onNext: { (value) in
                print(value)
            })
        .disposed(by: disposeBag)
        
        tableView.rx
        .itemAccessoryButtonTapped
            .subscribe(onNext: { (value) in
                print(value)
            })
        .disposed(by: disposeBag)
        
        
        
    }
}
