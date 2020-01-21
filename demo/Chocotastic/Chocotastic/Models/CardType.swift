//
//  CardType.swift
//  Chocotastic
//
//  Created by 周登杰 on 2019/10/26.
//  Copyright © 2019 zdj. All rights reserved.
//

import UIKit

enum CardType {
    case
    Unknown,
    Amex,
    Mastercard,
    Visa,
    Discover
    
    //https://en.wikipedia.org/wiki/Payment_card_number
    static func fromString(string: String) -> CardType {
        if string.isEmpty { return .Unknown }
        
        guard string.rw_allCharactersAreNumber() else {
            assertionFailure("One of these characters is not a number")
            return .Unknown
        }
        
        //Visa: Starts with 4
        //Mastercard: Starts with 2221-2720 or 51-55
        //Amex: Starts with 34 or 37
        //Discover: Starts with 6011, 622126-622925, 644-649, or 65
        if string.hasPrefix("4") {
            return .Visa
        }
        
        let firstTwo = string.rw_integerValueOfFirst(characters: 2)
        guard firstTwo != NSNotFound else { return .Unknown }
        
        switch firstTwo {
        case 51...55:
            return .Mastercard
        case 65:
            return .Discover
        case 34, 37:
            return .Amex
        default:
            break
        }
        
        let firstThree = string.rw_integerValueOfFirst(characters: 3)
        guard firstThree != NSNotFound else { return .Unknown }
        
        switch firstThree {
        case 644...649:
            return .Discover
        default:
            break
        }
        
        let firstFour = string.rw_integerValueOfFirst(characters: 4)
        guard firstFour != NSNotFound else { return .Unknown }
        
        switch firstFour {
        case 2221...2720:
            return .Mastercard
        case 6011:
            return .Discover
        default:
            break
        }
        
        let firstSix = string.rw_integerValueOfFirst(characters: 6)
        guard firstSix != NSNotFound else { return .Unknown }
        
        switch firstSix {
        case 622126...622925:
            return .Discover
        default:
            return .Unknown
        }
    }
    
    var expectedDigits: Int {
        switch self {
        case .Amex:
            return 15
        default:
            return 16
        }
    }
    
    var image: UIImage {
        switch self {
        case .Amex:
            return ImageName.Amex.image
        case .Discover:
            return ImageName.Discover.image
        case .Mastercard:
            return ImageName.Mastercard.image
        case .Visa:
            return ImageName.Visa.image
        case .Unknown:
            return ImageName.UnknownCard.image
        }
    }

    var cvvDigits: Int {
        switch self {
        case .Amex:
            return 4
        default:
            return 3
        }
    }
    
    func format(noSpaces: String) -> String {
        guard noSpaces.count >= 4 else { return noSpaces }
        
        let startIndex = noSpaces.startIndex
        
        let index4 = noSpaces.index(startIndex, offsetBy: 4)
        //All cards start with four digits before the get to spaces
        let firstFour = noSpaces.substring(to: index4)
        var formattedString = firstFour + " "
        
        switch self {
        case .Amex:
            //Amex format is xxxx xxxxxx xxxxx
            guard noSpaces.count > 10 else {
                return String(formattedString + noSpaces.suffix(from: index4))
            }
            
            let index10 = noSpaces.index(startIndex, offsetBy: 10)
            
            let nextSixRange = index4..<index10
            //let nextSixRange = Range(offsetRange)
            let nextSix = noSpaces[nextSixRange]
            let remaining = noSpaces.suffix(from: index10)
            
            return formattedString + nextSix + " " + remaining
            
        default:
            //Other cards are formatted as xxxx xxxx xxxx xxxx
            guard noSpaces.count > 8 else {
              //No further formatting required.
                return String(formattedString + noSpaces.suffix(from: index4))
            }
            
            let index8 = noSpaces.index(startIndex, offsetBy: 8)
            let nextFourRange = index4..<index8
            let nextFour = noSpaces[nextFourRange]
            formattedString += nextFour + " "
            
            guard noSpaces.count > 12 else {
              //Just add the remaining spaces
              let remaining = noSpaces.suffix(from: index8)
                return String(formattedString + remaining)
            }
            
            let index12 = noSpaces.index(startIndex, offsetBy: 12)
            let followingFourRange = index8..<index12
            let followingFour = noSpaces[followingFourRange]
            let remaining = noSpaces.suffix(from: index12)
            
            return formattedString + followingFour + " " + remaining
        }
    }
}
