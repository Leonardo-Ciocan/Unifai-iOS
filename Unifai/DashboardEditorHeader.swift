//
//  DashboardEditorHeader.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 17/07/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

class DashboardEditorHeader: UIView {
    @IBOutlet weak var shadowView: UIView!
    
    @IBOutlet weak var btnCreate: UIButton!
    @IBOutlet weak var txtMessage: UITextField!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib ()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib ()
    }
    
    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "DashboardEditorHeader", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        txtMessage.backgroundColor = UIColor.clear
        txtMessage.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.06).cgColor
        txtMessage.layer.borderWidth = 0
        txtMessage.textColor = UIColor.black
        txtMessage.layer.cornerRadius = 17.5
        txtMessage.layer.masksToBounds = true
        txtMessage.tintColor = UIColor.black
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        txtMessage.leftViewMode = .always
        txtMessage.leftView = leftView
        
        txtMessage.attributedPlaceholder = NSAttributedString(string: "Enter any message..." ,
                                                              attributes:[NSForegroundColorAttributeName: UIColor.gray])
        
        
        self.backgroundColor = UIColor.gray.lighter(amount:0.45)
        
        self.addSubview(view)
    }
    
    override func setNeedsLayout() {
//        shadowView.layer.shadowPath = UIBezierPath(roundedRect: shadowView.bounds, cornerRadius: 17.5).CGPath
//        self.shadowView.layer.shadowColor = UIColor.blackColor().CGColor
//        self.shadowView.layer.shadowOffset = CGSizeMake(0.0, 0.0)
//        self.shadowView.layer.shadowRadius = 10
//        self.shadowView.layer.shadowOpacity = 0.04
    }

    
}
