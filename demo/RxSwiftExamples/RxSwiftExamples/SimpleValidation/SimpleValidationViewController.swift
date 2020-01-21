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

class SimpleValidationViewController: UIViewController {

    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var usernamewarningLabel: UILabel!
    @IBOutlet weak var pwdTF: UITextField!
    @IBOutlet weak var pwdwarningLabel: UILabel!
    @IBOutlet weak var doSomethingBtn: UIButton!
    
    @IBAction func doSomething(_ sender: Any) {
        
    }
    
    
    private var viewModel: SimpleValidationViewModel!

    
    
    let disposeBag = DisposeBag()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        viewModel = SimpleValidationViewModel(
            username: usernameTF.rx.text.orEmpty.asObservable(),
            password: pwdTF.rx.text.orEmpty.asObservable()
        )
        
        viewModel.usernameValid
        .bind(to: pwdTF.rx.isEnabled)
        .disposed(by: disposeBag)
        
        viewModel.usernameValid
        .bind(to: usernamewarningLabel.rx.isHidden)
        .disposed(by: disposeBag)
        
        viewModel.passwordValid
        .bind(to: pwdwarningLabel.rx.isHidden)
        .disposed(by: disposeBag)
        
        viewModel.everythingValid
            .bind(to: doSomethingBtn.rx.isEnabled)
            .disposed(by: disposeBag)
        
        doSomethingBtn
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
