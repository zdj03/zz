//
//  ChocolateIsComingViewController.swift
//  Chocotastic
//
//  Created by 周登杰 on 2019/10/26.
//  Copyright © 2019 zdj. All rights reserved.
//

import UIKit

class ChocolateIsComingViewController: UIViewController {
    
    @IBOutlet var orderLabel: UILabel!
    @IBOutlet var costLabel: UILabel!
    @IBOutlet var creditCardIcon: UIImageView!
     
    var cardType: CardType = .Unknown {
       didSet {
         configureIconForCardType()
       }
     }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureIconForCardType()
        configureLabelsFromCart()
    }
    
    private func configureIconForCardType(){
        guard let imageView = creditCardIcon else {
            return
        }
        imageView.image = cardType.image
    }
    
    private func configureLabelsFromCart(){
        guard let costLabel = costLabel else {
            return
        }
        
        let cart = ShoppingCart.sharedCart
        
        costLabel.text = CurrencyFormatter.dollarsFormatter.rw_string(from: cart.totalCost())
        
        orderLabel.text = cart.itemCountString()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
