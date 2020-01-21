//
//  ChocolateCell.swift
//  Chocotastic
//
//  Created by 周登杰 on 2019/10/26.
//  Copyright © 2019 zdj. All rights reserved.
//

import UIKit

class ChocolateCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    static let Identifier = "ChocolateCell"
    
    @IBOutlet private var countryNameLabel: UILabel!
    @IBOutlet private var emojiLabel: UILabel!
    @IBOutlet private var priceLabel: UILabel!
    
    func configureWithChocolate(chocolate: Chocolate){
        countryNameLabel.text = chocolate.countryName
        emojiLabel.text = "🍫" + chocolate.countryFlagEmoji
        priceLabel.text = CurrencyFormatter.dollarsFormatter.rw_string(from: chocolate.priceInDollars)
    }

}
