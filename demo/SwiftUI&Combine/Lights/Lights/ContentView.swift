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
    
    @State var isShowHistory = false
   
    var body: some View {
        
        VStack(alignment: .leading) {
            
            HStack {
                Text("\(gManager.timeString)")
                               .font(.system(size: 45))
                
                Spacer()
                
                Text("\(gManager.clickTimes)步")
                    .font(.system(size: 45))
            }
           
            
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
                                    self.gManager.clickTimes += 1
                               }
                           }
                       }
                       .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
                   }
                   
                
                HStack {
                               Spacer()
                               
                               Button(action: {
                                   self.isShowHistory.toggle()
                               }) {
                                   Image(systemName:"clock")
                                       .imageScale(.large)
                                       .foregroundColor(.primary)
                               }
                               .frame(width:25, height:25)
                           }
                           .padding(20)
            .sheet(isPresented:$isShowHistory, content:{
                HistoryView()
            })
        }
        
        .alert(isPresented: $gManager.isWin) {
            Alert(title: Text("黑灯瞎火，摸鱼成功！"), dismissButton: .default(Text("继续摸鱼"), action: {
                 self.gManager.start([3,2,1])
                 self.gManager.timerRestart()
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
