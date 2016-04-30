//
//  ScheduleCell.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 29/04/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit
import MaterialDesignSymbol
import ActiveLabel

class ScheduleCell: UITableViewCell {

    @IBOutlet weak var lblRepeating: UILabel!
    @IBOutlet weak var lblStart: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var txtMessage: ActiveLabel!
    @IBOutlet weak var txtStart: UILabel!
    @IBOutlet weak var txtRepeating: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblMessage.font = MaterialDesignFont.fontOfSize(28)
        
        lblMessage.text = MaterialDesignIcon.textsms48px
        
        lblStart.font = MaterialDesignFont.fontOfSize(28)
        
        lblStart.text = MaterialDesignIcon.alarm48px
        
        lblRepeating.font = MaterialDesignFont.fontOfSize(28)
        
        lblRepeating.text = MaterialDesignIcon.schedule48px
        
        
    }

    func loadData(schedule:Schedule){
        txtMessage.text = schedule.content
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.LongStyle
        formatter.timeStyle = .MediumStyle
        
        txtStart.text = formatter.stringFromDate(schedule.startDate)
        txtRepeating.text = ["Only once" , "Every hour" , "Every day" , "Every week"][schedule.interval]
        
        var target = matchesForRegexInText("(?:^|\\s|$|[.])@[\\p{L}0-9_]*", text: schedule.content)
        if(target.count > 0){
            let name = target[0]
            let services = Core.Services.filter({"@"+$0.username == name})
            if(services.count > 0){
                txtMessage.mentionColor = (services[0].color)
            }
            else{
                txtMessage.mentionColor = Constants.appBrandColor
            }
        }
    }
    
}
