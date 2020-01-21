//
//  Chocolate.swift
//  Chocotastic
//
//  Created by 周登杰 on 2019/10/26.
//  Copyright © 2019 zdj. All rights reserved.
//

import Foundation

func ==(lhs: Chocolate, rhs: Chocolate) -> Bool {
    return (lhs.countryName == rhs.countryName)
        && (lhs.priceInDollars == rhs.priceInDollars)
        && (lhs.countryFlagEmoji == rhs.countryFlagEmoji)
}

struct Chocolate: Equatable {
    let priceInDollars: Float
    let countryName: String
    let countryFlagEmoji: String
    
    static let ofEurope: [Chocolate] = {
        let belgian = Chocolate(priceInDollars: 8,
                                countryName: "Belgium",
                                countryFlagEmoji: "🇧🇪")
        let british = Chocolate(priceInDollars: 7,
                                countryName: "Great Britain",
                                countryFlagEmoji: "🇬🇧")
        let dutch = Chocolate(priceInDollars: 8,
                              countryName: "The Netherlands",
                              countryFlagEmoji: "🇳🇱")
        let german = Chocolate(priceInDollars: 7,
                               countryName: "Germany", countryFlagEmoji: "🇩🇪")
        let swiss = Chocolate(priceInDollars: 10,
                              countryName: "Switzerland",
                              countryFlagEmoji: "🇨🇭")
        return [belgian, british, dutch, german, swiss]
    }()
}

extension Chocolate: Hashable {
    var hasValue: Int {
        return self.countryFlagEmoji.hashValue
    }
}


