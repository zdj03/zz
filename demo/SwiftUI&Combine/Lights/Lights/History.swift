//
//  History.swift
//  Lights
//
//  Created by 周登杰 on 2019/10/3.
//  Copyright © 2019 zdj. All rights reserved.
//

import Foundation

struct  History: Codable {
    
    /// 游戏创建时间
    let createTime: Date
    
    /// 游戏持续时间
    let durations: Int
    
    /// 游戏状态
    let isWin: Bool
    
    /// 游戏进行步数
    let clickTimes: Int
    
}
