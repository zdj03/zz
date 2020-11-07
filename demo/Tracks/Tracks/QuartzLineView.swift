//
//  QuartzLineView.swift
//  Tracks
//
//  Created by 周登杰 on 2020/11/6.
//


import PencilKit

import UIKit




class QuartzLineView: QuartzView {
    
    var dots: [Track] = []
    
    override func drawInContext(_ context: CGContext) {
        centerDrawing(inContext: context, drawingExtent: self.bounds,scaleToFit: true)
        
        context.setStrokeColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)

        context.savingGState {
    
            for dot in dots {
                switch dot {
                case .MoveTo(let d):
                    context.move(to: CGPoint(x: d.originX, y: d.originY))

                case .AddTo(let d):
                    print(d.pressure)
                    context.setLineWidth(d.pressure)
                    context.addLine(to: CGPoint(x: d.originX, y: d.originY))
                }
            }
        }
        context.strokePath()
    }
}

/*修改滚动视图的滚动范围
   if let dot = dot {
       if .MoveTo(let d) == dot {
           isWhitespacesAndNewlines = true
           if isDrawing {
               isDrawing = false
           }
       } else {
           if case let .Dot(dot: d) = dot {
               if isWhitespacesAndNewlines {
               } else {
                   context.move(to: CGPoint(x: d.originX, y: d.originY))
                   context.setLineWidth(d.pressure)
                   context.addLine(to: CGPoint(x: d.originX, y: d.originY))
                   context.strokePath()
               }
               isWhitespacesAndNewlines = false
               isDrawing = true
               
               let oldFrame = self.frame
               var newWidth = oldFrame.width
               var newHeight = oldFrame.height
               if oldFrame.width < d.originX {
                   newWidth = d.originX
               }
               if oldFrame.height < d.originY {
                   newHeight = d.originY
               }
               
               let newSize = CGSize(width: newWidth, height: newHeight)
               self.frame = CGRect(origin: oldFrame.origin, size: newSize)
               let scrollView = self.superview as! UIScrollView
               scrollView.contentSize = newSize
           }
       }
   }*/
