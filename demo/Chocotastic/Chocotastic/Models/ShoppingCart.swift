//
//  ShoppingCart.swift
//  Chocotastic
//
//  Created by 周登杰 on 2019/10/26.
//  Copyright © 2019 zdj. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ShoppingCart {
    static let sharedCart = ShoppingCart()
    
   /* var chocolates = [Chocolate](){
        didSet{
            print("chocolates has been changed")
        }
    }*/

//    将chocolates定义为一个RxSwift的Variable对象，其中泛型指定为Chocolate数组
// Variable是一个类，它使用引用语义，它有一个value属性，就是Chocolate对象数组的存储位置，它有个asObservable()方法，可以添加一个Observer来观察这个值，而不是每次手动去确认，当值发生变化时，Observer会通知你，以便对任何更新作出相应。这样有个缺点，即当你需要访问或更新Chocolates数组中的元素时，你必须使用value属性，而不思直接使用它

    let chocolates: Variable<[Chocolate]> = Variable([])
    
    
    
    //MARK: Non-Mutating Functions
    func totalCost() -> Float {
        return chocolates.value.reduce(0) {
            (runningTotal, chocolate) in
            return runningTotal + chocolate.priceInDollars
        }
    }
    
    func itemCountString() -> String {
        guard chocolates.value.count > 0 else {return "🚫🍫"}
        
        //Unique the chocolates
        let setOfChocolates = Set<Chocolate>(chocolates.value)
        
        //Check how many of each exists
        let itemStrings: [String] = setOfChocolates.map {
            (chocolate)in
            
            let count: Int = chocolates.value.reduce(0) {
                (runningTotal, reduceChocolate) in
                if chocolate == reduceChocolate {
                    return runningTotal + 1
                }
                return runningTotal
            }
            return "\(chocolate.countryFlagEmoji)🍫: \(count)"
        }
        return itemStrings.joined(separator: "\n")
    }
}
