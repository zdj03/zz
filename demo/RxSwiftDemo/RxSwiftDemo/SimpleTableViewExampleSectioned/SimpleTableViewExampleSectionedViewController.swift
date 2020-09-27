//
//  SimpleTableViewExampleSectionedViewController.swift
//  RxSwiftDemo
//
//  Created by 周登杰 on 2019/10/29.
//  Copyright © 2019 zdj. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SimpleTableViewExampleSectionedViewController: ViewController, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Double>> (
        configureCell:{ (_, tv, indexPath, element) -> UITableViewCell in
            let cell = tv.dequeueReusableCell(withIdentifier: "Cell")!
            cell.textLabel?.text = "\(element) @ row \(indexPath.row)"
            return cell
        },
        titleForHeaderInSection: {dataSource, sectionIndex in
            return dataSource[sectionIndex].model
        
        },
        canMoveRowAtIndexPath: { dataSource, sectionIndex in
            return true
        }
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let dataSource = self.dataSource
        
        let items = Observable.just([
            SectionModel(model: "First section", items: [
                1.0,
                2.0,
                3.0
            ]),
            SectionModel(model: "Second section", items: [
                1.0,
                2.0,
                3.0
            ]),
            SectionModel(model: "Third section", items: [
                1.0,
                2.0,
                3.0
            ]),
        ])
        
        items
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by:disposeBag)
        
           
        tableView.rx
        .itemSelected
            .map { indexPath in
                return (indexPath, dataSource[indexPath])
        }
        .subscribe(onNext: { (pair) in
            print("Tapped `\(pair.1) @ \(pair.0)`")
        })
        .disposed(by: disposeBag)
        
        tableView.rx
        .setDelegate(self)
        .disposed(by: disposeBag)
    }
    
    
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
