//
//  SimpleValidationViewModel.swift
//  RxSwiftExamples
//
//  Created by 周登杰 on 2019/10/28.
//  Copyright © 2019 zdj. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class SimpleValidationViewModel {
    //输出
    let usernameValid: Observable<Bool>
    let passwordValid: Observable<Bool>
    let everythingValid: Observable<Bool>
    
    //输入->输出
    init(
        username: Observable<String>,
        password: Observable<String>
    ) {
       usernameValid = username
            .map{ $0.count >= 5 }
            .share(replay: 1)
        
        passwordValid = password
            .map{ $0.count >= 5 }
        .share(replay: 1)
        
        everythingValid = Observable.combineLatest(usernameValid, passwordValid) {
            $0 && $1
        }
        .share(replay: 1)
    }
    
}
