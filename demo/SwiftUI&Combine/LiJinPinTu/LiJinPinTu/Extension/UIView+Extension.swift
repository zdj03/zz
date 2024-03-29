//
//  UIView+Extension.swift
//  LiJinPinTu
//
//  Created by 周登杰 on 2019/10/3.
//  Copyright © 2019 zdj. All rights reserved.
//

import UIKit

extension UIView {
    static private let ZZSCREEN_SCALE = UIScreen.main.scale
    
    private func getPixintegral(pointValue: CGFloat) -> CGFloat {
        return round(pointValue * UIView.ZZSCREEN_SCALE) / UIView.ZZSCREEN_SCALE
    }
    
    public var x: CGFloat{
        get {
            return self.frame.origin.x
        }
        set(x){
            self.frame = CGRect.init(
                x:getPixintegral(pointValue:x),
                y:self.y,
                width:self.width,
                height:self.height
                
            )
        }
    }
    
    public var y: CGFloat{
        get {
            return self.frame.origin.y
        }
        set(y){
            self.frame = CGRect.init(
                x:self.x,
                y:getPixintegral(pointValue:y),
                width:self.width,
                height:self.height
                
            )
        }
    }
    
    public var width: CGFloat{
        get {
            return self.frame.size.width
        }
        set(width){
            self.frame = CGRect.init(
                x:self.x,
                y:self.y,
                width:getPixintegral(pointValue:width),
                height:self.height
            )
        }
    }
    
    public var height: CGFloat{
        get {
            return self.frame.size.height
        }
        set(height){
            self.frame = CGRect.init(
                x:self.x,
                y:self.y,
                width:self.width,
                height:getPixintegral(pointValue: height)
            )
        }
    }
    
    public var bottom: CGFloat{
        get {
            return self.y + self.height
        }
        set(bottom){
            self.y = bottom - self.height
        }
    }
    
    public var right: CGFloat{
        get {
            return self.x + self.width
        }
        set(right){
            self.x = right - self.width
        }
    }
    
    public var left: CGFloat{
        get {
            return self.x
        }
        set(left){
            self.x = left
        }
    }
    
    public var top: CGFloat{
        get {
            return self.y
        }
        set(top){
            self.y = top
        }
    }
    
    public var centerX: CGFloat{
        get {
            return self.center.x
        }
        set(centerX){
            self.center = CGPoint.init(
                x: getPixintegral(pointValue:centerX),
                y: self.center.y
            )
        }
    }
    
    public var centerY: CGFloat{
        get {
            return self.center.y
        }
        set(centerY){
            self.center = CGPoint.init(
                x: self.center.x,
                y: getPixintegral(pointValue:centerY)
            )
        }
    }
    
}

extension UIView {
    func insertRoundingCorners(){
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 8.0, height: 8.0))
        let pathMaskLayer = CAShapeLayer()
        pathMaskLayer.frame = bounds
        pathMaskLayer.path = path.cgPath
        layer.mask = pathMaskLayer
    }
}
