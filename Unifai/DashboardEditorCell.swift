//
//  DashboardEditorCell.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 14/08/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit
import ActiveLabel

class DashboardEditorCell: UITableViewCell {

    @IBOutlet weak var txtMessage: ActiveLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.txtMessage.textColor = currentTheme.foregroundColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setMessage(msg : String) {
        self.txtMessage.text = msg
        if let color = TextUtils.extractServiceColorFrom(msg) {
            txtMessage.mentionColor = color
        }
    }
    
}
