//
//  ActionCell.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 01/05/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

class ActionCell: UITableViewCell {

    @IBOutlet weak var txtName: UILabel!
    @IBOutlet weak var txtMessage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    
    func loadData(action:Action){
        txtName.text = action.name
        txtMessage.text = action.message
        var target = matchesForRegexInText("(?:^|\\s|$|[.])@[\\p{L}0-9_]*", text: action.message)
        if(target.count > 0){
            let name = target[0]
            let services = Core.Services.filter({"@"+$0.username == name})
            if(services.count > 0){
                self.layer.backgroundColor = services[0].color.CGColor
            }
            else{
                
                
            }
        }
    }
    
    override func layoutSubviews() {
        contentView.frame = UIEdgeInsetsInsetRect(contentView.frame, UIEdgeInsetsMake(0, 0, 10, 0))
    }
}
