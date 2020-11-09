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
        path.flatness = 0.1
        path.move(to: startP)
        return path
    }
}



class QuartzLineView: QuartzView {
    
    var path: BHBPaintPath?
    var sLayer: CAShapeLayer?
    
    var curDot: Track?{
        didSet{
            if let curDot = curDot {
                switch curDot {
                case .MoveTo(let d):
                    path = BHBPaintPath.paintPathWithLineWidth(width: 0, startP: CGPoint(x: d.originX, y: d.originY))
                    let slayer = CAShapeLayer()
                    slayer.path = path?.cgPath
                    slayer.backgroundColor = UIColor.white.cgColor
                    slayer.fillColor = UIColor.white.cgColor
                    slayer.lineCap = .round
                    slayer.lineJoin = .round
                    slayer.strokeColor = UIColor.black.cgColor
                    slayer.lineWidth = d.pressure
                    self.layer.addSublayer(slayer)
                    sLayer = slayer;
                    
                case .AddTo(let d):
                    path?.lineWidth = d.pressure
                    path?.addLine(to: CGPoint(x: d.originX, y: d.originY))
                    sLayer?.path = path?.cgPath
                }
            }
        }
    }
}
