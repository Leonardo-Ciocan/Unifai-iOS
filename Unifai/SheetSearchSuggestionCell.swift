//
//  SheetSearchSuggestionCell.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 16/09/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

class SheetSearchSuggestionCell: UICollectionViewCell {

    @IBOutlet weak var txtName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        txtName.layer.cornerRadius = 7.5
        txtName.layer.masksToBounds = true
    }
    
    
    
}
