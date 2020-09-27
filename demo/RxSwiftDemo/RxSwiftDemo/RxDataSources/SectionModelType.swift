//
//  SectionModelType.swift
//  RxSwiftDemo
//
//  Created by 周登杰 on 2019/10/29.
//  Copyright © 2019 zdj. All rights reserved.
//

import Foundation

/*
 `self` 与 `Self`区别：
 
 self：可以用在类型后面取得类型本身，也可以用在实例后面取得实例本身
 
 Self：不仅指代实现该协议的类型本身，也包括了这个类型的子类
 
 */

public protocol SectionModelType {
    associatedtype Item
    
    var items: [Item] {get}
    
    
    // 协议定一个方法，接受实现该协议的自身类型并返回一个同样的类型
    init(original: Self, items: [Item])

    
}
