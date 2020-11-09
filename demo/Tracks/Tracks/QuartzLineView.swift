//
//  QuartzLineView.swift
//  Tracks
//
//  Created by 周登杰 on 2020/11/6.
//


import PencilKit

import UIKit

class QuartzLineView: QuartzView {
    
    var curDot: Track?{
        didSet{
            if let dot = curDot {
                self.dots.append(dot)
            }
        }
    }
    
    var lastDot: Track?
    
    var dots: [Track] = []{
        didSet{
//            self.setNeedsDisplay()
        }
    }
    
    
    override func drawInContext(_ context: CGContext) {
        
        let beginDate = Date()
        
        centerDrawing(inContext: context, drawingExtent: self.bounds,scaleToFit: true)
        
        context.setStrokeColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        context.savingGState {
        
            for dot in dots {
                switch dot {
                case .MoveTo(_):
                    lastDot = dot
                case .AddTo(let d):
                    if case .MoveTo(let dd) = lastDot {
                        context.move(to: CGPoint(x: dd.originX, y: dd.originY))
                    }
                    context.setLineWidth(d.pressure)
                    context.addLine(to: CGPoint(x: d.originX, y: d.originY))
                    context.strokePath()
                    lastDot = .MoveTo(dot: d)
                
                }
            }
        print(Date().timeIntervalSince(beginDate) * 1000)
        
        }
    }
}
