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
    
    func loadData(_ payload : CardListPayloadItem , service:Service){
        if !(payload.imageURL?.isEmpty)!{
            Alamofire.request(payload.imageURL!)
                .responseImage { response in
                    if let image = response.result.value {
                        self.imageView.image = image.af_imageAspectScaled(toFill: CGSize(width: 200, height: 200))
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
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CardView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.backgroundColor = UIColor.white
        self.backgroundColor = UIColor.white
        
        self.addSubview(view);
    }
    
    override func draw(_ rect: CGRect) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.12
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 5
        
    }

}
