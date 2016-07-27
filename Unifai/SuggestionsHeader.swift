//
//  SuggestionsHeader.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 27/07/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

class SuggestionsHeader: UIView {

    var color : UIColor?
    var text : String?
    @IBOutlet weak var txtName : UILabel!
    
    init(frame: CGRect , color : UIColor) {
        super.init(frame: frame)
        self.color = color
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
        let nib = UINib(nibName: "SuggestionsHeader", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        view.backgroundColor = currentTheme.backgroundColor
        self.backgroundColor = currentTheme.backgroundColor
        view.backgroundColor = color
        self.addSubview(view)
    }

}
