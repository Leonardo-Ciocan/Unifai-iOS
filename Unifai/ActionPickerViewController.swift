//
//  ActionPickerViewController.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 14/07/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

protocol ActionPickerDelegate {
    func selectedAction(message : String)
}

class ActionPickerViewController: UIViewController , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var actions : [Service:[Action]] = [:]
    var serviceOrder : [Service] = []
    var delegate : ActionPickerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.collectionView.registerNib(UINib(nibName: "ActionCell", bundle: nil), forCellWithReuseIdentifier: "ActionCell")
        self.collectionView.registerNib(UINib(nibName: "ActionsHeader",bundle:nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.setActions(Core.Actions)
        self.collectionView.reloadData()


        self.collectionView.backgroundColor = currentTheme.backgroundColor
        
        self.navigationItem.title = "Pick an action"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(CancelTapped))
        self.applyCurrentTheme()
    }
    
    func setActions(actions : [Action]) {
        self.actions = [:]
        self.serviceOrder = []
        for action in actions {
            let service = TextUtils.extractService(action.message)
            if service == nil {
                continue
            }
            if !serviceOrder.contains(service!) {
                serviceOrder.append(service!)
            }
            if let _ = self.actions[service!] {
                self.actions[service!]!.append(action)
            }
            else{
                self.actions[service!] = [action]
            }
        }
    }
    
    @IBAction func CancelTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return serviceOrder.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let service = self.serviceOrder[section]
        return (self.actions[service]?.count)!
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ActionCell", forIndexPath: indexPath) as! ActionCell
        let service = serviceOrder[indexPath.section]
        cell.loadData(actions[service]![indexPath.row])
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenRect = self.collectionView.frame
        let screenWidth = screenRect.size.width
        let cellWidth = screenWidth / 2.0
        let size = CGSizeMake(cellWidth-15, 100)
        return size
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        delegate?.selectedAction(self.actions[serviceOrder[indexPath.section]]![indexPath.row].message)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let header =  collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "header", forIndexPath: indexPath) as! ActionsHeader
        
        let service = serviceOrder[indexPath.section]
        
        header.txtName.textColor = service.color
        header.txtCount.textColor = currentTheme.secondaryForegroundColor
        
        header.txtName.text = service.name.uppercaseString
        header.txtCount.text = String(actions[service]!.count) + " actions"
        
        return header
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 70)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return currentTheme.statusBarStyle
    }
}
