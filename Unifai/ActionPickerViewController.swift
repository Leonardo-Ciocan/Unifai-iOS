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

class ActionPickerViewController: UIViewController , UICollectionViewDataSource , UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var actions : [Action] = []
    var delegate : ActionPickerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.collectionView.registerNib(UINib(nibName: "ActionCell", bundle: nil), forCellWithReuseIdentifier: "ActionCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        getServicesAndUser({ _ in
            
            Unifai.getActions({ actions in
                self.actions = actions
                self.collectionView.reloadData()
            })
        })

    }
    
    func getServicesAndUser(callback: ([Service]) -> () ){
        if Core.Services.count > 0 {
            callback(Core.Services)
            return
        }
        Unifai.getServices({ services in
            Unifai.getUserInfo({username , email in
                Core.Username = username
                callback(services)
            })
        })
    }
    
    @IBAction func CancelTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return actions.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ActionCell", forIndexPath: indexPath) as! ActionCell
        //cell.backgroundColor = UIColor.redColor()
        cell.loadData(actions[indexPath.row])
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenRect = UIScreen.mainScreen().bounds
        let screenWidth = screenRect.size.width
        let cellWidth = screenWidth / 2.0
        let size = CGSizeMake(cellWidth-15, 100)
        return size
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        delegate?.selectedAction(self.actions[indexPath.row].message)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
