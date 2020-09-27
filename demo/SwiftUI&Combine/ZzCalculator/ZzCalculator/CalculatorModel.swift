//
//  CalculatorModel.swift
//  ZzCalculator
//
//  Created by 周登杰 on 2019/10/7.
//  Copyright © 2019 zdj. All rights reserved.
//

import Combine
import SwiftUI

class CalculatorModel: ObservableObject {
    @Published var brain: CalculatorBrain = .left("0")
    
    @Published var history: [CalculatorButtonItem] = []
    
    func apply(_ item: CalculatorButtonItem) {
        brain = brain.apply(item: item)
        history.append(item)
    }
    
    var historyDetail: String {
        history.map {
            $0.description
        }.joined()
    }
    
    var temporaryKept: [CalculatorButtonItem] = []
    
    var totalCount: Int {
        history.count + temporaryKept.count
    }
    
    var slidingIndex: Float = 0 {
        didSet {
            //维护history 和 temporaryKept
            keepHistory(upTo: Int(slidingIndex))
        }
    }
    
    func keepHistory(upTo index: Int) {
        precondition(index <= totalCount, "Out of index.")
        
        let total = history + temporaryKept
        
        history = Array(total[index...])
        temporaryKept = Array(total[index...])
        
        brain = history.reduce(CalculatorBrain.left("0"), { (result, item) in
            result.apply(item: item)
        })
    }
    
}
