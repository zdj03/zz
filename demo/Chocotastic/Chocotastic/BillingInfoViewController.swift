//
//  BillingInfoViewController.swift
//  Chocotastic
//
//  Created by 周登杰 on 2019/10/26.
//  Copyright © 2019 zdj. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BillingInfoViewController: UIViewController {
    
    @IBOutlet private var creditCardNumberTextField: ValidatingTextField!
    @IBOutlet private var creditCardImageView: UIImageView!
    @IBOutlet private var expirationDateTextField: ValidatingTextField!
    @IBOutlet private var cvvTextField: ValidatingTextField!
    @IBOutlet private var purchaseButton: UIButton!
    
    private let disposeBag = DisposeBag()
    private let throttleInterval = 0.1//设置0.1秒为单位抖动
    
    private let cardType: Variable<CardType> = Variable(.Unknown)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "💳Info"
        
        setupCardImageDisplay()
        setupTextChangeHandling()
    }
    
//MARK: - Rx Setup
    private func setupCardImageDisplay(){
        cardType
        .asObservable()
            .subscribe(onNext: {
                (cardType) in
                self.creditCardImageView.image = cardType.image
            }, onError: { (error) in
                print(error.localizedDescription)
            }, onCompleted: {
                print("onCompleted")
            }) {
                print("onDisposed")
        }
    .addDisposableTo(disposeBag)
    }
    
    private func setupTextChangeHandling() {
        let creditCardValid = creditCardNumberTextField
        .rx//textfield
        .text//1、将textfield的text作为Observable值
        .throttle(throttleInterval, scheduler: MainScheduler.instance)//2、限制输入，以便设置的验证基于设置的时间间隔才运行。scheduler参数绑定到一个线程，这里绑定到主线程
            .map { self.validate(cardText: $0!) } //3、将被限制的输入应用于validate(cardText:)来转换
        
        creditCardValid
            .subscribe(onNext: {//4、接收所创建的Observable值并订阅，根据传入的值来更新textfield的验证
                self.creditCardNumberTextField.valid = $0
            })
            .addDisposableTo(disposeBag)
        
        
        let expirationValid = expirationDateTextField
        .rx
        .text
        .throttle(throttleInterval, scheduler: MainScheduler.instance)
        .map { self.validate(expirationDateText: $0!)}
        
        expirationValid
            .subscribe(onNext: {
                self.expirationDateTextField.valid = $0
            })
            .addDisposableTo(disposeBag)
     
        
        let cvvValid = cvvTextField
        .rx
        .text
        .map { self.validate(cvvText: $0!)}
        
        cvvValid
            .subscribe(onNext: {
                self.cvvTextField.valid = $0
            }, onError: { (error) in
                print(error.localizedDescription)
            }, onCompleted: {
                print("onCompleted")
            }) {
                print("onDisposed")
        }
    .addDisposableTo(disposeBag)
        
        
        //将前面创建的三个Observable组合成第四个变量，然后将everything绑定到UIButton的响应扩展的enable属性上
        let everythingValid = Observable.combineLatest(creditCardValid, expirationValid, cvvValid){
            $0 && $1 && $2
        }
        
        everythingValid
            .bindTo(purchaseButton.rx.isEnabled)
        .addDisposableTo(disposeBag)
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        let identifier = identifierForSegue(segue: segue)
        switch identifier {
        case .PurchaseSuccess:
            guard let destination = segue.destination as? ChocolateIsComingViewController else {
                assertionFailure("Couldn't get chocolate is coming VC!")
                return
            }
            destination.cardType = cardType.value
        }
    }
    
    //MARK: - Validation methods
    func validate(cardText: String) -> Bool {
        let noWhitespace = cardText.rw_removeSpaces()
        
        updateCardType(using: noWhitespace)
        formatCardNumber(using: noWhitespace)
        advanceIfNecessary(noSpacesCardNumber: noWhitespace)
        
        guard cardType.value != .Unknown else {
            return false
        }
        
        guard noWhitespace.rw_isLuhnValid() else {
            return false
        }
        
        return noWhitespace.count == self.cardType.value.expectedDigits
    }
    
    func validate(expirationDateText expiration: String) -> Bool {
        let strippedSlashExpiration = expiration.rw_removeSlash()
        
        formatExpirationDate(using: strippedSlashExpiration)
        advanceIfNecessary(noSpacesCardNumber: strippedSlashExpiration)
        
        return strippedSlashExpiration.rw_isValidExpirationDate()
    }
    
    func validate(cvvText cvv: String) -> Bool {
        guard cvv.rw_allCharactersAreNumber() else {
            return false
        }
        
        dismissIfNecessary(cvv: cvv)
        
        return cvv.count == self.cardType.value.cvvDigits
    }
    
    
    //MARK: Single-serve helper functions
    private func updateCardType(using noSpacesNumber: String){
        cardType.value = CardType.fromString(string: noSpacesNumber)
    }
    
    private func formatCardNumber(using nospacesCardNumber: String){
        creditCardNumberTextField.text = self.cardType.value.format(noSpaces: nospacesCardNumber)
    }
    
    func advanceIfNecessary(noSpacesCardNumber: String) {
        if noSpacesCardNumber.count == self.cardType.value.expectedDigits {
            self.expirationDateTextField.becomeFirstResponder()
        }
    }
    
    func formatExpirationDate(using expirationNoSpacesOrSlash: String) {
        expirationDateTextField.text = expirationNoSpacesOrSlash.rw_addSlash()
    }
    
    func dismissIfNecessary(cvv: String) {
        if cvv.count == self.cardType.value.cvvDigits {
            let _ = self.cvvTextField.resignFirstResponder()
        }
    }
}

extension BillingInfoViewController: SegueHandler {
    enum SegueIdentifier: String {
        case PurchaseSuccess
    }
}
