//
//  LoginButton.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 01/06/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

class LoginButton: UIView {
    
    @IBOutlet weak var loginText: UILabel!
    
    var service : Service?
    
    func setService(s : Service){
        service = s
        loginText.text = "Login to " + s.name
        loginText.textColor = service?.color

        //self.backgroundColor = s.color
        //self.layer.backgroundColor = s.color.CGColor
        setNeedsDisplay()
    }
    
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
        let nib = UINib(nibName: "LoginButton", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        view.backgroundColor = currentTheme.backgroundColor
        
        self.addSubview(view);
    }
    
    
    let newLayer = CALayer()

    override func drawRect(rect: CGRect) {
        //guard service != nil else { return }
        newLayer.borderColor = service?.color.CGColor
        newLayer.borderWidth = 1
        newLayer.cornerRadius = 2
        newLayer.backgroundColor = UIColor.clearColor().CGColor
        //newLayer.frame = CGRect(x: 10, y: 0, width: self.frame.width-10, height: self.frame.height)
        
        newLayer.cornerRadius = 10
        newLayer.masksToBounds = true
        self.layer.addSublayer(newLayer)

        super.drawRect(rect)
    }
    
    override func layoutSubviews() {
        newLayer.frame = self.layer.bounds
    }
}
