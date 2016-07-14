//
//  CatalogItemCell.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 05/07/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

class CatalogItemCell: UITableViewCell {

    @IBOutlet weak var imgAction: UIImageView!
    @IBOutlet weak var whiteView: UIView!
    @IBOutlet weak var txtText: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
