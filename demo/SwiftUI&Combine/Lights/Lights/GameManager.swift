//
//  GameManager.swift
//  Lights
//
//  Created by 周登杰 on 2019/9/28.
//  Copyright © 2019 zdj. All rights reserved.
//

import SwiftUI
import Combine

class GameManager: ObservableObject {
    @Published var lights = [[Light]]()
    @Published var isWin = false
    
    private var currentStatus: GameStatus = .during {
        didSet{
            switch currentStatus {
            case .win:
                isWin = true
            case .lose:
                isWin = false
            case .during:
                break
            }
        }
    }
    
    /// 游戏尺寸大小
    private(set) var size: Int?
    
    
    
    /// - Init
    init() {}
    
    
    
    convenience init(size: Int = 5,
                     lightSequence: [Int] = [Int]() ) {
        self.init()
        
        var size = size
        
        if size > 8 {
            size = 7
        }
        
        if size < 2 {
            size = 2
        }
        
        self.size = size
        lights = Array(repeating: Array(repeating: Light(), count: size), count: size)
        
        start(lightSequence)
    }
    
    func start(_ lightSequence: [Int]){
        currentStatus = .during
        updateLightStatus(lightSequence)
    }
    
    
    private func updateGameStatus(){
        guard let size = size else {
            return
        }
        
        var lightingCount = 0
        
        for lightArr in lights {
            for light in lightArr {
                if light.status {
                    lightingCount += 1
                }
            }
            
            if lightingCount == size * size {
                currentStatus = .lose
                return
            }
            
            if lightingCount == 0 {
                currentStatus = .win
                return
            }
        }
    }
    
    func circleWidth() -> CGFloat {
        guard let size = size else {
            return 0
        }
        
        let padding: CGFloat = 20
        
        let innerSpacing: CGFloat = 20
        
        var circleWidth = (UIScreen.main.bounds.width - padding - innerSpacing * (CGFloat)(size)) / CGFloat(size)
        
        if circleWidth > UIScreen.main.bounds.width / 5 {
            circleWidth = UIScreen.main.bounds.width / 5
        }
        
        
        return circleWidth
    }
    
    
    
    /// 通过灯亮序列修改灯状态
    /// - Parameter lightSequence: 亮灯序列
    private func updateLightStatus(_ lightSequence: [Int]) {
           guard let size = size else {
               return
           }
           
           for lightIndex in lightSequence {
               var row = lightIndex / size
               let column = lightIndex % size
               
               if column > 0 && row > 0 {
                   row += 1
               }
               
               updateLightStatus(column: column, row: row)
           }
    }
    
    
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
        
            updateGameStatus()
       }
}


extension GameManager{
    enum GameStatus {
        case win
        case lose
        case during
    }
}
