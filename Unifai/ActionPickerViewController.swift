//
//  ActionPickerViewController.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 14/07/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

protocol ActionPickerDelegate {
    func selectedAction(_ message : String)
}

class ActionPickerViewController: UIViewController , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var actions : [Service:[Action]] = [:]
    var serviceOrder : [Service] = []
    var delegate : ActionPickerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.collectionView.register(UINib(nibName: "ActionCell", bundle: nil), forCellWithReuseIdentifier: "ActionCell")
        self.collectionView.register(UINib(nibName: "ActionsHeader",bundle:nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.setActions(Core.Actions)
        self.collectionView.reloadData()


        self.collectionView.backgroundColor = currentTheme.backgroundColor
        
        self.navigationItem.title = "Pick an action"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(CancelTapped))
        self.applyCurrentTheme()
        
        self.navigationController?.navigationBar.barTintColor = currentTheme.backgroundColor
        self.navigationController?.navigationBar.tintColor = currentTheme.foregroundColor
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    func setActions(_ actions : [Action]) {
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
    
    @IBAction func CancelTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return serviceOrder.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let service = self.serviceOrder[section]
        return (self.actions[service]?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActionCell", for: indexPath) as! ActionCell
        let service = serviceOrder[(indexPath as NSIndexPath).section]
        cell.loadData(actions[service]![(indexPath as NSIndexPath).row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenRect = self.collectionView.frame
        let screenWidth = screenRect.size.width
        let cellWidth = screenWidth / 2.0
        let size = CGSize(width: cellWidth-15, height: 100)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.selectedAction(self.actions[serviceOrder[(indexPath as NSIndexPath).section]]![(indexPath as NSIndexPath).row].message)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! ActionsHeader
        
        let service = serviceOrder[(indexPath as NSIndexPath).section]
        
        header.txtName.textColor = service.color
        header.txtCount.textColor = currentTheme.secondaryForegroundColor
        
        header.txtName.text = service.name.uppercased()
        header.txtCount.text = String(actions[service]!.count) + " actions"
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 70)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return currentTheme.statusBarStyle
    }
}
