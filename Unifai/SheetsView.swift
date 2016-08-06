//
//  SheetsView.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 05/08/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

protocol SheetsViewDelegate {
    func shouldOpenLinkWithURL(url:String)
    func shouldSendMessageWithText(text:String, sourceRect:CGRect, sourceView:UIView)
}
class SheetsView: UIView, UICollectionViewDelegate , UICollectionViewDataSource , SheetCellDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    var sheets : [Sheet] = []
    var color : UIColor?
    var delegate : SheetsViewDelegate?

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
        let nib = UINib(nibName: "SheetsView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        view.backgroundColor = currentTheme.backgroundColor
        
        self.addSubview(view);
        collectionView.backgroundColor = UIColor.clearColor()
        
        collectionView.registerNib(UINib(nibName:"SheetCell",bundle: nil), forCellWithReuseIdentifier: "SheetCell")
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 77, bottom: 0, right: 10)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sheets.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SheetCell", forIndexPath: indexPath) as! SheetCell
        cell.loadEntries(sheets[indexPath.row].entries)
        cell.backgroundColor = color
        cell.delegate = self
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 180, height: collectionView.frame.height)
    }
    
    func loadSheets(sheets:[Sheet],color:UIColor) {
        self.sheets = sheets
        self.color = color
        self.collectionView.reloadData()
    }
    
    func shouldOpenLinkWithURL(url: String) {
        self.delegate?.shouldOpenLinkWithURL(url)
    }
    func shouldSendMessageWithText(text: String, sourceRect: CGRect, sourceView: UIView) {
        delegate?.shouldSendMessageWithText(text, sourceRect: sourceRect, sourceView: sourceView)
    }
}
