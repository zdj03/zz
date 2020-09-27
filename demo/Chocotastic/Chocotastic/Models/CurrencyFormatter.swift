//
//  CurrencyFormatter.swift
//  Chocotastic
//
//  Created by 周登杰 on 2019/10/26.
//  Copyright © 2019 zdj. All rights reserved.
//

import Foundation

enum CurrencyFormatter {
    static let dollarsFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter
    }()
}

extension NumberFormatter {
    
    func rw_string(from float: Float) -> String? {
        return self.string(from: NSNumber(value: float))
    }
}
