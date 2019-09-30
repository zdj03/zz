//
//  ContentView.swift
//  Lights
//
//  Created by 周登杰 on 2019/9/27.
//  Copyright © 2019 zdj. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
     @ObservableObject var manager = GameManager()
    
    
    /// 圆形图案之间的间距
    private let innerSpacing = 30
    
    var body: some View {
       
        ForEach(0..<manager.lights.count) {
            rowIndex in
            HStack(spacing:20) {
                ForEach(0..<self.manager.lights[rowIndex].count) {
                    columnIndex in
                    Circle()
                        .foregroundColor(self.manager.lights[rowIndex][columnIndex].status ? .yellow : .gray)
                        .opacity(self.manager.lights[rowIndex][columnIndex].status ? 0.8 : 0.5)
                    .frame(width: UIScreen.main.bounds.width / 5, height: UIScreen.main.bounds.width / 5)
                        .shadow(color: .yellow, radius: self.manager.lights[rowIndex][columnIndex].status ? 10 : 0)
                        .tapAction {
                            self.manager.updateLightStatus(column: columnIndex, row: rowIndex)
                    }
                }
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
        }
    }
    
    
   
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
