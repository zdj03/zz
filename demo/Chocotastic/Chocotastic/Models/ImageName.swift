//
//  ImageName.swift
//  Chocotastic
//
//  Created by 周登杰 on 2019/10/26.
//  Copyright © 2019 zdj. All rights reserved.
//

import UIKit

enum ImageName: String {
    case
    Amex,
    Discover,
    Mastercard,
    Visa,
    UnknownCard
    
    var image: UIImage {
        guard let image = UIImage(named: self.rawValue) else {
            fatalError("Image not found for name \(self.rawValue)")
        }
        return image
    }
}
