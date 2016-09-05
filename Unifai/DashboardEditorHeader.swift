//
//  DashboardEditorHeader.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 17/07/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

class DashboardEditorHeader: UIView {
    
    @IBOutlet weak var btnCreate: UIButton!
    @IBOutlet weak var txtMessage: MessageCreatorTextView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib ()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib ()
    }
    
    func loadViewFromNib() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "DashboardEditorHeader", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        txtMessage.layer.borderColor = currentTheme.foregroundColor.CGColor
        txtMessage.textColor = currentTheme.foregroundColor
        txtMessage.backgroundColor = currentTheme.shadeColor
        
        txtMessage.attributedPlaceholder = NSAttributedString(string: "Enter any message..." ,
                                                              attributes:[NSForegroundColorAttributeName: currentTheme.secondaryForegroundColor])
        
        
        
        self.addSubview(view)
    }

    
}
