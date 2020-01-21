//
//  segueHandler.swift
//  Chocotastic
//
//  Created by 周登杰 on 2019/10/26.
//  Copyright © 2019 zdj. All rights reserved.
//

import UIKit

protocol SegueHandler {
    associatedtype SegueIdentifier: RawRepresentable
}

extension SegueHandler where Self: UIViewController, SegueIdentifier.RawValue == String {
    func performSegueWithIdentifier(identifier: SegueIdentifier, sender: AnyObject?){
        performSegue(withIdentifier: identifier.rawValue, sender: sender)
    }
    
    func identifierForSegue(segue: UIStoryboardSegue) -> SegueIdentifier {
        guard let stringIdentifier = segue.identifier, let identifier = SegueIdentifier(rawValue: stringIdentifier) else {
            fatalError("Couldn't find identifier for sugue")
        }
        return identifier
    }
}
