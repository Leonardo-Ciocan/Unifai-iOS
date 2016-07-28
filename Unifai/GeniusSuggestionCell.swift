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

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func loadData(data:GeniusSuggestion) {
        txtName.text = data.name.uppercaseString
        txtMessage.text = data.message
        let service = extractService(data.message)
//        imgLogo.backgroundColor = service?.color
//        imgLogo.image = UIImage(named: (service?.username)!)
//        
//        imgLogo.layer.cornerRadius = imgLogo.frame.width / 2.0
//        imgLogo.layer.masksToBounds = true
        
        innerView.backgroundColor = service?.color
        innerView.layer.cornerRadius = 5
        innerView.layer.masksToBounds = true
        txtName.textColor = UIColor.whiteColor()
        txtMessage.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.7)
    }
    
    override func layoutSubviews() {
    }
    
}
