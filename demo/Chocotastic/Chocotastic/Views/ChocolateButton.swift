//
//  ChocolateButton.swift
//  Chocotastic
//
//  Created by 周登杰 on 2019/10/26.
//  Copyright © 2019 zdj. All rights reserved.
//

import UIKit

@IBDesignable
class ChocolateButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override var isEnabled: Bool {
        didSet {
            updateAlphaForEnabledState()
        }
    }
    
    enum _ButtonType {
        case
        Standard,
        Warning
    }
    
/*
    IB_DESIGNABLE 让你的自定 UIView 可以在 IB 中预览。
    IBInspectable 让你的自定义 UIView 的属性出现在 IB 中 Attributes inspector 。
*/
    
    @IBInspectable var isStandard: Bool = false {
        didSet {
            if isStandard {
                type = .Standard
            } else {
                type = .Warning
            }
        }
    }
    
    private var type: _ButtonType = .Standard {
        didSet {
            updateBackgroundColorForCurrentType()
        }
    }
    
    private func commonInit(){
        self.setTitleColor(.white, for: .normal)
        updateBackgroundColorForCurrentType()
        updateAlphaForEnabledState()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonInit()
    }
    
    func updateAlphaForEnabledState(){
        switch type {
        case .Standard:
            self.backgroundColor = .brown
        case .Warning:
            self.backgroundColor = .red
        }
    }
    
    func updateBackgroundColorForCurrentType(){
        if isEnabled {
            self.alpha = 1
        } else {
            self.alpha = 0.5
        }
    }

}
