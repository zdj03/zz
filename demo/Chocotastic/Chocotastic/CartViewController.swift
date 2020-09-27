//
//  CartViewController.swift
//  Chocotastic
//
//  Created by 周登杰 on 2019/10/26.
//  Copyright © 2019 zdj. All rights reserved.
//

import UIKit

class CartViewController: UIViewController {
    
    @IBOutlet private var checkoutButton: UIButton!
    @IBOutlet private var totalItemsLabel: UILabel!
    @IBOutlet private var totalCostLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "Cart"
        configureFromCart()
    }
    
    
    private func configureFromCart(){
        guard checkoutButton != nil else {
            return
        }

        let cart = ShoppingCart.sharedCart
        totalItemsLabel.text = cart.itemCountString()
        
        let cost = cart.totalCost()
        totalCostLabel.text = CurrencyFormatter.dollarsFormatter.rw_string(from: cost)
        
        checkoutButton.isEnabled = (cost > 0)
    }
    
    @IBAction func reset(){
        ShoppingCart.sharedCart.chocolates.value = []
        let _ = navigationController?.popViewController(animated: true)
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
