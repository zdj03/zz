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
    @ObservedObject var gManager = GameManager(size: 5, lightSequence: [1,2,3])
   
    var body: some View {

        ForEach(0..<gManager.lights.count) {
            rowIndex in
            HStack(spacing:20) {
                ForEach(0..<self.gManager.lights[rowIndex].count) {
                    columnIndex in
                    Circle()
                        .foregroundColor(self.gManager.lights[rowIndex][columnIndex].status ? .yellow : .gray)
                        .opacity(self.gManager.lights[rowIndex][columnIndex].status ? 0.8 : 0.5)
                        .frame(width: self.gManager.circleWidth(), height: self.gManager.circleWidth())
                        .shadow(color: .yellow, radius: self.gManager.lights[rowIndex][columnIndex].status ? 10 : 0)
                        .onTapGesture {
                            self.gManager.updateLightStatus(column: columnIndex, row: rowIndex)
                    }
                }
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
        }
        .alert(isPresented: $gManager.isWin) {
            Alert(title: Text("黑灯瞎火，摸鱼成功！"), dismissButton: .default(Text("继续摸鱼"), action: {
                self.gManager.start([3,2,1])
            }
                )
            )
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
