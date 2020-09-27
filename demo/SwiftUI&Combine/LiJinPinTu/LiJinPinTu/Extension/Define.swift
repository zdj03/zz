//
//  Define.swift
//  LiJinPinTu
//
//  Created by 周登杰 on 2019/10/3.
//  Copyright © 2019 zdj. All rights reserved.
//

import UIKit

/// 屏幕宽
let screenWidth = UIScreen.main.bounds.size.width
/// 屏幕高
let screenHeight = UIScreen.main.bounds.size.height
/// 底部安全距离
let bottomSafeAreaHeight = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0.0
///顶部的安全距离
let topSafeAreaHeight = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0.0
/// 状态栏高度
let statusBarHeight = UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.width
/// 导航栏高度
let navigationBarHeight = CGFloat(44 + topSafeAreaHeight)
