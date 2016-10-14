//
//  GeniusSuggestionCell.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 28/07/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

class GeniusSuggestionCell: UITableViewCell {

    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var txtName: UILabel!
    @IBOutlet weak var txtMessage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func loadData(_ data:GeniusSuggestion) {
        txtName.text = data.name.uppercased()
        txtMessage.text = data.message
        if let service = TextUtils.extractService(data.message) {
            innerView.backgroundColor = service.color
        }
        else {
            innerView.backgroundColor = Constants.appBrandColor
        }
        
        innerView.layer.cornerRadius = 5
        innerView.layer.masksToBounds = true
        txtName.textColor = UIColor.white
        txtMessage.textColor = UIColor.white.withAlphaComponent(0.7)
    }
    
}
