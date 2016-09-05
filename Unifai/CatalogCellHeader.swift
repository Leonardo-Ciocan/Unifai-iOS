//
//  CatalogCellHeader.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 22/08/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

class CatalogCellHeader: UIView {

    var parentViewController : UIViewController?
    @IBOutlet weak var visitProfile: UIButton!
    @IBOutlet weak var txtServiceName: UILabel!
    @IBOutlet weak var imgLogo: UIImageView!
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
        let nib = UINib(nibName: "CatalogCellHeader", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        visitProfile.layer.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2).CGColor
        visitProfile.layer.cornerRadius = 5
        visitProfile.layer.masksToBounds = true
        
        self.addSubview(view)
    }

    var service : Service?
    func loadData(service:Service) {
        self.service = service
        txtServiceName.text = service.name.uppercaseString
        visitProfile.setTitle("Visit @\(service.username) profile", forState: .Normal)
        imgLogo.image = UIImage(named: service.username)
        self.backgroundColor = service.color.darkenColor(0.08)
        
        //visitProfile.layer.backgroundColor = service.color.CGColor
        //txtServiceName.textColor = service.color
    }

    @IBAction func visitProfile(sender: AnyObject) {
        guard let service = self.service else { return }
        let profileVC = UIStoryboard(name: "Feed", bundle: nil).instantiateViewControllerWithIdentifier("profile") as! ServiceProfileViewcontroller
        profileVC.loadData(service)
        let nav = UINavigationController(rootViewController: profileVC)
        
        nav.modalPresentationStyle = .Popover
        let viewForSource = sender as! UIView
        nav.popoverPresentationController!.sourceView = viewForSource
        
        // the position of the popover where it's showed
        nav.popoverPresentationController!.sourceRect = viewForSource.bounds
        
        // the size you want to display
        nav.preferredContentSize = CGSizeMake(300,450)
        
        self.parentViewController!.presentViewController(nav, animated: true, completion: nil)
    }
}
