//
//  String+CreditCard.swift
//  Chocotastic
//
//  Created by 周登杰 on 2019/10/26.
//  Copyright © 2019 zdj. All rights reserved.
//

import Foundation

extension String {
    func rw_allCharactersAreNumber() -> Bool {
        let nonNumberCharacterSet = NSCharacterSet.decimalDigits.inverted
        return (self.rangeOfCharacter(from: nonNumberCharacterSet) == nil)
    }
    
    func rw_integerValueOfFirst(characters: Int) -> Int {
        guard rw_allCharactersAreNumber() else { return NSNotFound }
        
        if characters > self.count { return NSNotFound }
        
        let indexToStopAt = self.index(self.startIndex, offsetBy: characters)
        //let substring = self.prefix(through: indexToStopAt)
        let substring = self.substring(to: indexToStopAt)
        guard let integerValue = Int(substring) else { return NSNotFound }
        
        return integerValue
    }
    
    //https://www.rosettacode.org/wiki/Luhn_test_of_credit_card_numbers
    func rw_isLuhnValid() -> Bool {
        guard self.rw_allCharactersAreNumber() else { return false }
        
        let reversed = self.reversed().map { (String($0)) }
        
        var sum = 0
        for (index, element) in reversed.enumerated() {
            guard let digit = Int(element) else { return false }
            
            if index % 2 == 1 {// Even digit
                switch digit {
                case 9:
                    sum += 9
                default:
                    sum += ((digit * 2) % 9)
                }
            } else {//Odd digit
                sum += digit
            }
        }
        //valid if divisible by 10
        return sum % 10 == 0
    }
    
    func rw_removeSpaces() -> String {
        return self.replacingOccurrences(of: " ", with: "")
    }
}
