//
//  UIImage+Extension.swift
//  LiJinPinTu
//
//  Created by 周登杰 on 2019/10/3.
//  Copyright © 2019 zdj. All rights reserved.
//

import UIKit

extension UIImage {
    
    /// 通过原图获取rect大小的图片
    func image(with rect: CGRect) -> UIImage {
        let scale: CGFloat = 1
        let x = rect.origin.x * scale
        let y = rect.origin.y * scale
        let w = rect.width * scale
        let h = rect.height * scale
        let finalRect = CGRect(x: x, y: y, width: w, height: h)
        
        let originImageRef = self.cgImage
        
        
        /// f如果finalRect超出self.size，finalImageRef为nil
        let finalImageRef = originImageRef!.cropping(to: finalRect)
        let finalImage = UIImage(cgImage: finalImageRef!, scale: scale, orientation: .up)
        
        return finalImage
        
    }
}
