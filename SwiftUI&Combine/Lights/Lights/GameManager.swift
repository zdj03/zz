//
//  GameManager.swift
//  Lights
//
//  Created by 周登杰 on 2019/9/28.
//  Copyright © 2019 zdj. All rights reserved.
//

import SwiftUI
import Combine

class GameManager: ObservedObject {
       @Published var lights = [
            [Light(),Light(status: true),Light()],
            [Light(),Light(),Light()],
            [Light(),Light(),Light()]
        ]
    
    /// 通过坐标索引修改灯的状态
       /// - Parameter column: 列
       /// - Parameter row: 行
       func updateLightStatus(column: Int, row: Int) {
           lights[row][column].status.toggle()
           
           let top = row - 1
           if !(top < 0) {
               lights[top][column].status.toggle()
           }
           
           let bottom = row + 1
           if !(bottom > lights.count - 1) {
               lights[bottom][column].status.toggle()
           }
           
           let left = column - 1
           if !(left < 0) {
               lights[row][left].status.toggle()
           }
           
           let right = column + 1
           if !(right > lights.count - 1) {
               lights[row][right].status.toggle()
           }
       }
}
