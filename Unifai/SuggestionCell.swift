//
//  SuggestionCell.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 24/07/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

class SuggestionCell: UITableViewCell {

    @IBOutlet weak var txtMessage: UILabel!
    @IBOutlet weak var txtName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.clearColor()
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
