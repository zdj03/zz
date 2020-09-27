//
//  Puzzle.swift
//  LiJinPinTu
//
//  Created by 周登杰 on 2019/10/3.
//  Copyright © 2019 zdj. All rights reserved.
//

import UIKit

class Puzzle: UIImageView {
    
    var panChange: ((CGPoint) -> ())?
    var panEnded: (() -> ())?
    
    /// 是否拷贝拼图元素
    private var isCopy = false
    private var rightPoint: CGFloat = 0
    private var leftPoint: CGFloat = 0
    private var topPoint: CGFloat = 0
    private var bottomPoint: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(size: CGSize, isCopy: Bool) {
        self.init(frame: CGRect(x: -1000, y: -1000, width: size.width, height: size.height))
        self.isCopy = isCopy
        
        initView()
    }
    
    func initView(){
        contentMode = .scaleAspectFit
        
       // backgroundColor = .red
        
        if !isCopy {
            isUserInteractionEnabled = true

            let panGesture = UIPanGestureRecognizer(target: self, action: .pan)
            self.addGestureRecognizer(panGesture)
        } else {
            transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }
    
    
    func updateEdge() {
        if superview != nil {
            if !isCopy {
                topPoint = topSafeAreaHeight
                bottomPoint = superview!.bottom - bottomSafeAreaHeight
                rightPoint = superview!.width / 2
                leftPoint = 0
            }
        }else {
            if superview != nil {
                topPoint = superview!.top
                bottomPoint = superview!.bottom
                rightPoint = superview!.width
                leftPoint = superview!.width / 2
            }
        }
    }
    
    
    /// i移动'rightPuzzle'、
    /// - Parameter centerPoint: <#centerPoint description#>
    func copyPuzzleCenterChange(centerPoint: CGPoint){
        if !isCopy {
            return
        }
        center = CGPoint(x: screenWidth - centerPoint.x, y: centerPoint.y)
    }
}

extension Puzzle {
    @objc
    fileprivate func pan(_ panGesture: UIPanGestureRecognizer) {
        let translation = panGesture.translation(in: superview)
        
        switch panGesture.state {
        case .began:
            layer.borderColor = UIColor.white.cgColor
            layer.borderWidth = 1
        case .changed:
            if right > rightPoint {
                right = rightPoint
            }
            if left < leftPoint {
                left = leftPoint
            }
            if top < topPoint {
                top = topPoint
            }
            if bottom > bottomPoint {
                bottom = bottomPoint
            }
        case .ended:
            layer.borderWidth = 0
            self.panEnded?()
        default:
            break
        }
        
        
        center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
        panGesture.setTranslation(.zero, in: superview)

        panChange?(center)
    }
}


private extension Selector {
    static let pan = #selector(Puzzle.pan(_:))
}
