//
//  QuartzLineView.swift
//  Tracks
//
//  Created by 周登杰 on 2020/11/6.
//


import PencilKit

import UIKit

class BHBPaintPath: UIBezierPath{

    static func paintPathWithLineWidth(width: CGFloat,startP:CGPoint) -> BHBPaintPath{
        let path = BHBPaintPath()
        path.lineWidth = width
        path.lineCapStyle = .round //线条拐角
        path.lineJoinStyle = .round //终点处理
        path.flatness = 1
        path.move(to: startP)
        return path
    }
}



class QuartzLineView: QuartzView {
    
    var path: BHBPaintPath?
    var sLayer: CAShapeLayer?
    var lastDot: Dot?
    
    var curDot: Track?{
        didSet{
            if let curDot = curDot {
                switch curDot {
                case .MoveTo(let d):
                    lastDot = d
                    
                case .AddTo(let d):
                    
//                    if path == nil {
                        path = BHBPaintPath.paintPathWithLineWidth(width: d.pressure, startP: CGPoint(x: d.originX, y: d.originY))
//                    } else {
//                        path!.lineWidth = d.pressure
//                        path!.move(to: CGPoint(x: d.originX, y: d.originY))
//                    }
                    
//                    if sLayer == nil {
                        let slayer = CAShapeLayer()
                        slayer.backgroundColor = UIColor.white.cgColor
                        slayer.fillColor = UIColor.white.cgColor
                        slayer.lineCap = .round
                        slayer.lineJoin = .round
                        slayer.strokeColor = UIColor.black.cgColor
                        sLayer = slayer
//                    }
                    sLayer!.lineWidth = path!.lineWidth
                    self.layer.addSublayer(sLayer!)


                    path!.addLine(to: CGPoint(x: d.originX, y: d.originY))
                    sLayer!.path = path!.cgPath
                    lastDot = d
                    
                    
                    print(self.layer.sublayers!)
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let startP = pointWithTouches(touches: touches)
        if event?.allTouches?.count == 1 {
            path = BHBPaintPath.paintPathWithLineWidth(width: CGFloat(arc4random()%3+1), startP: startP)
            
            let slayer = CAShapeLayer()
            slayer.path = path?.cgPath
            slayer.backgroundColor = UIColor.white.cgColor
            slayer.fillColor = UIColor.white.cgColor
            slayer.lineCap = .round
            slayer.lineJoin = .round
            slayer.strokeColor = UIColor.black.cgColor
            slayer.lineWidth = path!.lineWidth
            self.layer.addSublayer(slayer)
            sLayer = slayer
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let moveP = pointWithTouches(touches: touches)
        if (event?.allTouches!.count)! > 1 {
            self.superview?.touchesMoved(touches, with: event)
        }else if event?.allTouches?.count == 1 {
            path?.addLine(to: moveP)
            sLayer?.path = path?.cgPath
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (event?.allTouches!.count)! > 1 {
            self.superview?.touchesMoved(touches, with: event)
        }
    }
    
    // 根据touches集合获取对应的触摸点
    func pointWithTouches(touches: Set<UITouch>) -> CGPoint {
        let touch = ((touches as NSSet).anyObject() as AnyObject)     //进行类  型转化

        let point = touch.location(in:self)     //获取当前点击位置
        return point
    }
}

