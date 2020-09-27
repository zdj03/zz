//
//  ValidatingTextField.swift
//  Chocotastic
//
//  Created by 周登杰 on 2019/10/26.
//  Copyright © 2019 zdj. All rights reserved.
//

import UIKit

class ValidatingTextField: UITextField {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var valid: Bool = false {
        didSet {
            configureForValid()
        }
    }
    
    var hasBeenExited: Bool = false {
        didSet {
            configureForValid()
        }
    }
    
    func commonInit(){
        configureForValid()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func resignFirstResponder() -> Bool {
        hasBeenExited = true
        return super.resignFirstResponder()
    }
    
    private func configureForValid(){
        if !valid && hasBeenExited {
            self.backgroundColor = .red
        } else {
            backgroundColor = .clear
        }
    }

}
