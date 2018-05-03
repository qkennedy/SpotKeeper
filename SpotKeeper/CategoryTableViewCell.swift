//
//  CategoryTableViewCell.swift
//  SpotKeeper
//
//  Created by Quinn Kennedy on 5/3/18.
//  Copyright © 2018 Quinn Kennedy. All rights reserved.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var categoryTitle: UILabel!
    @IBOutlet weak var colorSwatchView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
