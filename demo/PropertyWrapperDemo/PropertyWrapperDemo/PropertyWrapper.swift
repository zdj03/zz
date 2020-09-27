//
//  PropertyWrapper.swift
//  ZzCalculator
//
//  Created by 周登杰 on 2019/10/7.
//  Copyright © 2019 zdj. All rights reserved.
//

import Foundation


@propertyWrapper public struct Converter {
    let from: String
    let to: String
    let rate: Double
    
    var value: Double
    
    public var wrappedValue: String {
        get {
            "\(from) \(value)"
        }
        set {
            value = Double(newValue) ?? -1
        }
    }
    
    public var projectedValue: String {
        return "\(to) \(value * rate)"
    }
    
    public init(initialValue: String,
         from: String,
         to: String,
         rate: Double) {
        self.rate = rate
        self.value = 0
        self.from = from
        self.to = to
        self.wrappedValue = initialValue
    }
}
