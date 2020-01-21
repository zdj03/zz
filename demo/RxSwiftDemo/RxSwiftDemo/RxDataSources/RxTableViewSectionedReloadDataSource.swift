//
//  RxTableViewSectionedReloadDataSource.swift
//  RxSwiftDemo
//
//  Created by 周登杰 on 2019/10/29.
//  Copyright © 2019 zdj. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

open class RxTableViewSectionedReloadDataSource<Section: SectionModelType>: TableViewSectionedDataSource<Section>, RxTableViewDataSourceType {
    public typealias Element = [Section]
    
    open func tableView(_ tableView: UITableView, observedEvent: Event<Element>) {
        Binder(self) { (dataSource, element) in
            dataSource.setSections(element)
            tableView.reloadData()
        }.on(observedEvent)
    }
}
