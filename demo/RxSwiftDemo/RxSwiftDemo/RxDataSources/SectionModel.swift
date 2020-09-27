//
//  SectionModel.swift
//  RxSwiftDemo
//
//  Created by 周登杰 on 2019/10/29.
//  Copyright © 2019 zdj. All rights reserved.
//

import Foundation


public struct SectionModel<Section, ItemType> {
    public var model: Section
    public var items: [Item]
    
    public init(model: Section, items: [Item]){
        self.model = model
        self.items = items
    }
}

extension SectionModel: SectionModelType {
    public typealias Identity = Section
    public typealias Item = ItemType
    
    public var identity: Section {
        return model
    }
}

extension SectionModel: CustomStringConvertible {
    public var description: String {
        return "\(self.model) > \(items)"
    }
}

extension SectionModel {
    public init(original: SectionModel<Section, Item>, items: [Item]) {
        self.model = original.model
        self.items = items
    }
}
