//
//  SimpleValidationViewController.swift
//  RxSwift
//
//  Created by 周登杰 on 2019/10/27.
//  Copyright © 2019 zdj. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

private let minimalUsernameLength = 5
private let minimalPasswordLength = 5

class SimpleValidationViewController: UIViewController {

    @IBOutlet weak var usernameOutlet: UITextField!
    @IBOutlet weak var usernameValidOutlet: UILabel!

    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var passwordValidOutlet: UILabel!

    @IBOutlet weak var doSomethingOutlet: UIButton!
    
    
    private var viewModel: SimpleValidationViewModel!

    
    
    let disposeBag = DisposeBag()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        usernameValidOutlet.text = "Username has to be at least \(minimalUsernameLength) characters"
        passwordValidOutlet.text = "Password has to be at least \(minimalPasswordLength) characters"
        
        
        viewModel = SimpleValidationViewModel(
            username: usernameOutlet.rx.text.orEmpty.asObservable(),
            password: passwordOutlet.rx.text.orEmpty.asObservable()
        )
        
        viewModel.usernameValid
        .bind(to: passwordOutlet.rx.isEnabled)
        .disposed(by: disposeBag)
        
        viewModel.usernameValid
        .bind(to: usernameValidOutlet.rx.isHidden)
        .disposed(by: disposeBag)
        
        viewModel.passwordValid
        .bind(to: passwordValidOutlet.rx.isHidden)
        .disposed(by: disposeBag)
        
        viewModel.everythingValid
            .bind(to: doSomethingOutlet.rx.isEnabled)
            .disposed(by: disposeBag)
        
        doSomethingOutlet
        .rx
        .tap
        .subscribe(
            onNext: {
                [weak self] in self?.showAlert()
        })
        .disposed(by: disposeBag)
        
        
    }
    
    func showAlert(){
        let alert = UIAlertView(title: "RxExample", message: "This is wonderful", delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
}
