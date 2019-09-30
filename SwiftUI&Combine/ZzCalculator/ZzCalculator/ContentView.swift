//
//  ContentView.swift
//  ZzCalculator
//
//  Created by 周登杰 on 2019/9/26.
//  Copyright © 2019 zdj. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    let scale: CGFloat = UIScreen.main.bounds.width / 414
    
    var body: some View {
        
        VStack(spacing: 12) {
            
            HStack{
                Spacer()
                Text("0")
                                       .font(.system(size:76))
                                       .minimumScaleFactor(0.5)
                                       .padding(.trailing,24)
                                       .lineLimit(1)
                                       .frame(
                                        minHeight: 0, maxHeight: .infinity, alignment: .bottom)
            }
                   CalculatorButtonPad()
                   .padding(.bottom)
               }
               .scaleEffect(scale)
        
//        VStack(spacing: 12) {
//            Spacer()
//            Text("0")
//                .font(.system(size:76))
//                .minimumScaleFactor(0.5)
//                .padding(.trailing,24)
//                .lineLimit(1)
//                .frame(minWidth: 0, maxWidth: .infinity,alignment: .trailing)
//            CalculatorButtonPad()
//            .padding(.bottom)
//        }
//        .scaleEffect(scale)
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        Group{
            ContentView().environment(\.colorScheme, .dark)

            ContentView().previewDevice("iPhone SE")
            
            ContentView().previewDevice("iPad Air 2")
        }
    }
}
#endif

struct CalculatorButton: View {
    let fontSize: CGFloat = 38
    let title: String
    let size: CGSize
    let backgroundColorName: String
    let action:()->Void
    
    var body: some View {
        
        return ZStack {
          
            Text(title)
                .font(.system(size: fontSize))
                .frame(width:size.width,height: size.height)
                .foregroundColor(.white)
                .background(Color(backgroundColorName))
                .clipShape(Circle())

                
        }
        
//        return Button(action: action) {
//            Text(title)
//                .font(.system(size: fontSize))
//                .frame(width:size.width,height: size.height)
//                .foregroundColor(.white)
//                .background(Color(backgroundColorName))
//                .cornerRadius(size.width/2)
//        }
    }
}


struct CalculatorButtonRow: View {
    let row: [CalculatorButtonItem]

    var body: some View {
        
        HStack{
            ForEach(row, id: \.self) {
                item in
                CalculatorButton(
                title: item.title, size: item.size, backgroundColorName: item.backgroundColorName)
                {
                    print("Button: \(item.title)")
                }
            }
        }
    }
}


struct CalculatorButtonPad: View {
    
    let pad: [[CalculatorButtonItem]] = [
    [.command(.clear),.
                    command(.flip),.command(.percent),.op(.divide)
                ],
    [.digit(7),.digit(8),.digit(9),.op(.multiply)
                            ],
    [.digit(4),.digit(5),.digit(6),.op(.minus)
                ],
    [.digit(1),.digit(2),.digit(3),.op(.plus)
                ],
    [.digit(0),.dot,.op(.equal)]
    ]
    
    var body: some View {
        
        VStack(spacing: 8) {
            ForEach(pad, id:\.self) {
                row in
                CalculatorButtonRow(row: row)
            }
        }
    }
}
