//
//  NSDate+CurrentComponents.swift
//  Chocotastic
//
//  Created by 周登杰 on 2019/10/26.
//  Copyright © 2019 zdj. All rights reserved.
//

import Foundation

extension Date {
    static func rw_gregorianCalendar() -> NSCalendar{
        guard let calendar = NSCalendar(calendarIdentifier: .gregorian) else {
            fatalError("couldn't instantiate gregorian calendar?!")
        }
        return calendar
    }
    
    func rw_currentYear() -> Int {
        return Date.rw_gregorianCalendar().component(.year, from: self)
    }
    
    func rw_currentMonth() -> Int {
        return Date.rw_gregorianCalendar().component(.month, from: self)
    }
}
