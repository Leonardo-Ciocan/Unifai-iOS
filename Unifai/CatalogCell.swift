//
//  CatalogCell.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 05/07/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit
import DynamicColor

extension UIView {
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.frame, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.CGPath
        self.layer.mask = mask
    }
}
class CatalogCell: UICollectionViewCell , UITableViewDelegate , UITableViewDataSource {

    
    var parentViewController : UIViewController? {
        didSet {
            self.header?.parentViewController = parentViewController
        }
    }
    var header : CatalogCellHeader?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.registerNib(UINib(nibName: "CatalogItemCell" , bundle: nil), forCellReuseIdentifier: "CatalogItemCell")
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        
        header = CatalogCellHeader(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 120))
        tableView.tableHeaderView = header
        
        tableView.layer.cornerRadius = 10
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 100))
        tableView.layer.masksToBounds = true
    }
    
    var items : [CatalogItem] = []
    
    @IBAction func visit(sender: AnyObject) {
        print("ayuyyy")
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CatalogItemCell", forIndexPath: indexPath) as! CatalogItemCell
        cell.txtText.text = items[indexPath.row].name
        cell.txtDescription.text = items[indexPath.row].description
        cell.backgroundView?.backgroundColor = UIColor.clearColor()
        cell.contentView.backgroundColor = serviceColor!.lightenColor(0.05)
        cell.imgAction.image = cell.imgAction.image?.imageWithRenderingMode(.AlwaysTemplate)
        cell.imgAction.tintColor = UIColor.whiteColor()
        cell.backgroundColor = UIColor.clearColor()
        cell.parentViewController = self.parentViewController
        
        cell.item = items[indexPath.row]
        return cell
    }
    
    
    
    var serviceColor : UIColor?
    @IBOutlet weak var tableView: UITableView!
    func loadData(service:Service) {
        self.serviceColor = service.color
        
        self.tableView.separatorStyle = .SingleLine
        self.tableView.separatorInset = UIEdgeInsetsZero
        self.tableView.separatorColor = serviceColor?.darkenColor(0.05)
        self.header?.loadData(service)
        
        items = Core.Catalog[service.name.lowercaseString] ?? []
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
    }

}
