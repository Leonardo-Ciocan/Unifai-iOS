//
//  ActionCell.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 01/05/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

class ActionCell: UICollectionViewCell {

    @IBOutlet weak var blur: UIVisualEffectView!
    @IBOutlet weak var txtName: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func loadData(action:Action){
        txtName.text = action.name
        var target = matchesForRegexInText("(?:^|\\s|$|[.])@[\\p{L}0-9_]*", text: action.message)
        if(target.count > 0){
            let name = target[0]
            let services = Core.Services.filter({"@"+$0.username == name})
            if(services.count > 0){
                //self.layer.backgroundColor = services[0].color.CGColor
                self.backgroundImage.image = UIImage(named: services[0].username)
            }
            else{
                
            }
        }
    }
    
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
    }
    
}
