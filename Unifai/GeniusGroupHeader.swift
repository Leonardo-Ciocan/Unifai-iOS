//
//  GeniusGroupHeader.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 28/07/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

class GeniusGroupHeader: UIView {

    @IBOutlet weak var txtName: UILabel!
    
    init(frame: CGRect , color : UIColor) {
        super.init(frame: frame)
        loadViewFromNib ()
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
        let nib = UINib(nibName: "GeniusGroupHeader", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.addSubview(view)
    }

}
