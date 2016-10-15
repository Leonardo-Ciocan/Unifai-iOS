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
    func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.frame, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
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
        
        tableView.register(UINib(nibName: "CatalogItemCell" , bundle: nil), forCellReuseIdentifier: "CatalogItemCell")
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        
        header = CatalogCellHeader(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 120))
        tableView.tableHeaderView = header
        
        //tableView.layer.cornerRadius = 10
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 100))
        //tableView.layer.masksToBounds = true
    }
    
    var items : [CatalogItem] = []
    
    @IBAction func visit(_ sender: AnyObject) {
        print("ayuyyy")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CatalogItemCell", for: indexPath) as! CatalogItemCell
        cell.txtText.text = items[(indexPath as NSIndexPath).row].name
        cell.txtDescription.text = items[(indexPath as NSIndexPath).row].description
        cell.backgroundView?.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = serviceColor!.lighter(amount: 0.05)
        cell.imgAction.image = cell.imgAction.image?.withRenderingMode(.alwaysTemplate)
        cell.imgAction.tintColor = UIColor.white
        cell.backgroundColor = UIColor.clear
        cell.parentViewController = self.parentViewController
        
        cell.item = items[(indexPath as NSIndexPath).row]
        return cell
    }
    
    
    
    var serviceColor : UIColor?
    @IBOutlet weak var tableView: UITableView!
    func loadData(_ service:Service) {
        self.serviceColor = service.color.darkened(amount:0.18)
        
//        self.tableView.separatorStyle = .SingleLine
//        self.tableView.separatorInset = UIEdgeInsetsZero
//        self.tableView.separatorColor = serviceColor?.darkenColor(0.05)
        self.header?.loadData(service)
        
        items = Core.Catalog[service.name.lowercased()] ?? []
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
    }

}
