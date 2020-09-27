//
//  CalculatorBrain.swift
//  ZzCalculator
//
//  Created by 周登杰 on 2019/9/26.
//  Copyright © 2019 zdj. All rights reserved.
//

import Foundation


enum CalculatorBrain {
    case left(String)
    case leftOp(
        left: String,
        op: CalculatorButtonItem.Op
    )
    case leftOpRight(
        left: String,
        op: CalculatorButtonItem.Op,
        right: String
    )
    case error
    
    var formatter: NumberFormatter {
        let f = NumberFormatter()
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 8
        f.numberStyle = .decimal
        return f
    }
    
    var output: String {
        var result: String = ""
        switch self {
        case .left(let left):
            result = left
//        case .leftOp(left: , op: ):
//        case .leftOpRight(left: , op: , right: ):
//        case .error:
            
        default:
            break
        }
        
        guard let value = Double(result) else {
            return "Error"
        }
        return formatter.string(from: value as NSNumber)!
    }
    
    typealias CalculatorState = CalculatorBrain
    typealias CalculatorStateAction = CalculatorButtonItem
    
    struct Reducer{
        static func reduce(
            state: CalculatorState,
            action: CalculatorStateAction
        ) ->CalculatorState {
            return state.apply(item: action)
        }
    }
    
    func apply(item: CalculatorButtonItem) -> CalculatorBrain {
        switch item {
        case .digit(let num):
            return apply(num: num)
        case .dot:
            return applyDot()
        case .op(let op):
            return apply(op: op)
        case .command(let command):
            return apply(command: command)
        }
    }
    
    func apply(num: Int) -> CalculatorBrain {
        return self
    }
    func applyDot() -> CalculatorBrain{
        return self
    }
    func apply(op: CalculatorButtonItem.Op) -> CalculatorBrain {
        return self
    }
    func apply(command: CalculatorButtonItem.Command) -> CalculatorBrain {
        return self
    }
    
}
