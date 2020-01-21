//
//  String+ExpirationDate.swift
//  Chocotastic
//
//  Created by 周登杰 on 2019/10/26.
//  Copyright © 2019 zdj. All rights reserved.
//

import Foundation


extension String {
    func rw_addSlash() -> String {
        guard self.count > 2 else { return self }
        
        let index2 = self.index(self.startIndex, offsetBy: 2)
        let firstTwo = self.substring(to: index2)
        let rest = self.substring(from: index2)
        
        return firstTwo + " / " + rest
    }
    
    func rw_removeSlash() -> String {
        let removedSpaces = self.rw_removeSpaces()
        return removedSpaces.replacingOccurrences(of: "/", with: "")
    }
    
    func rw_isValidExpirationDate() -> Bool {
        let noSlash = self.rw_removeSlash()
        guard noSlash.count == 6 && noSlash.rw_allCharactersAreNumber() else { return false}
        
        let index2 = self.index(self.startIndex, offsetBy: 2)
        let monthString = self.substring(to: index2)
        let yearString = self.substring(from: index2)
        
        guard let month = Int(monthString), let year = Int(yearString) else { return false }
        guard (month >= 1 && month <= 12) else { return false }
        
        let now = Date()
        let currentYear = now.rw_currentYear()
        
        guard year >= currentYear else { return false }
        
        if year == currentYear {
            let currentMonth = now.rw_currentMonth()
            guard month >= currentMonth else { return false }
        }
        return true
    }
}
