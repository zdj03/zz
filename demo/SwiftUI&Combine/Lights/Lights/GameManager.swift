//
//  GameManager.swift
//  Lights
//
//  Created by 周登杰 on 2019/9/28.
//  Copyright © 2019 zdj. All rights reserved.
//

import SwiftUI
import Combine
import Foundation

class GameManager: ObservableObject {
    @Published var lights = [[Light]]()
    @Published var isWin = false
    
    
    /// 对外发布的格式化计时器字符串
    @Published var timeString = "00:00"
    
    /// 游戏计时器
    private var timer: Timer?
    
    /// 游戏持续时间
    private var durations = 0
    
    @Published var clickTimes = 0
    
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
        
        timerRestart()
    }
    
    private func save(){
        let documentUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        let historyUrl = documentUrl.appendingPathComponent("gameHistory.plist")
        
        let history = History(createTime: Date(), durations: durations, isWin: isWin, clickTimes: clickTimes)
        var gameHistorys = NSArray(contentsOf: historyUrl)
        if gameHistorys == nil {
            gameHistorys = [History]() as NSArray
        }
        
        gameHistorys?.adding(history)
        
        gameHistorys!.write(to: historyUrl, atomically: true)
        
    }
    
    func timerStop(){
        timer?.invalidate()
        timer = nil
    }
    
    func timerRestart(){
        self.durations = 0
        self.timeString = "00:00"
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ timer in
            self.durations += 1
            
            let min = self.durations >= 60 ? self.durations / 60 : 0
            let seconds = self.durations - min * 60
            
            let minString = min > 10 ? "\(min)" : "0\(min)"
            let secondString = seconds >= 10 ? "\(seconds)" : "0\(seconds)"
            self.timeString = minString + ":" + secondString
            
        }
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
                
                timerStop()
                return
            }
            
            if lightingCount == 0 {
                currentStatus = .win
                
                timerStop()
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
