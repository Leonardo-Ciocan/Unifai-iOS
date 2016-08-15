//
//  CardView.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 02/06/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire

class CardView: UIView {
    
    var navigateURL = ""
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var txtTitle: UILabel!
    
    func loadData(payload : CardListPayloadItem , service:Service){
        if !(payload.imageURL?.isEmpty)!{
            Alamofire.request(.GET, payload.imageURL!)
                .responseImage { response in
                    if let image = response.result.value {
                        self.imageView.image = image.af_imageAspectScaledToFillSize(CGSize(width: 200, height: 200))
                    }
            }
        }
        else{
            imageView.image = UIImage(named: service.username)
        }
        txtTitle.text = payload.title
        self.navigateURL = payload.navigateURL!
        imageView.backgroundColor = service.color
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
        let nib = UINib(nibName: "CardView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        view.backgroundColor = UIColor.whiteColor()
        self.backgroundColor = UIColor.whiteColor()
        
        self.addSubview(view);
    }
    
    override func drawRect(rect: CGRect) {
        self.layer.cornerRadius = 5
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOffset = CGSizeMake(0.0, 0.0)
        self.layer.shadowRadius = 5.0
        self.layer.shadowOpacity = 0.0
        self.layer.masksToBounds = true
        
    }

}
