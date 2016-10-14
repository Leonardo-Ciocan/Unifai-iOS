//
//  SheetsView.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 05/08/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

protocol SheetsViewDelegate {
    func shouldOpenLinkWithURL(_ url:String)
    func shouldSendMessageWithText(_ text:String, sourceRect:CGRect, sourceView:UIView)
    func shouldOpenSheetsManagerWithSheets(_ sheets:[Sheet], service:Service)
}

class SheetsView: UIView, UICollectionViewDelegate , UICollectionViewDataSource , SheetCellDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var btnFilter: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    var sheets : [Sheet] = []
    var color : UIColor?
    var delegate : SheetsViewDelegate?
    var service : Service?

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
        let nib = UINib(nibName: "SheetsView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = UIColor.clear
        
        self.addSubview(view);
        collectionView.backgroundColor = UIColor.clear
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 60
        layout.minimumLineSpacing = 15
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout

        collectionView.register(UINib(nibName: "SheetCell", bundle: nil), forCellWithReuseIdentifier: "SheetCell")
        collectionView.register(UINib(nibName: "SheetsViewHeader", bundle: nil), forSupplementaryViewOfKind: "UICollectionElementKindSectionHeader", withReuseIdentifier: "header")
        collectionView.delegate = self
        collectionView.dataSource = self
    }
  
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sheets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SheetCell", for: indexPath) as! SheetCell
        cell.service = self.service
        cell.loadEntries(sheets[(indexPath as NSIndexPath).row].entries)
        cell.backgroundColor = color
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: collectionView.frame.height - 40)
    }
    
    func loadSheets(_ sheets:[Sheet],color:UIColor,service:Service?) {
        self.sheets = sheets
        self.color = color
        self.service = service
        self.btnFilter.tintColor = color
        self.collectionView.reloadData()
    }
    
    func shouldOpenLinkWithURL(_ url: String) {
        self.delegate?.shouldOpenLinkWithURL(url)
    }
    
    @IBAction func tappedFilter(_ sender: AnyObject) {
        self.delegate?.shouldOpenSheetsManagerWithSheets(sheets, service: service!)
        
    }
    
    func shouldSendMessageWithText(_ text: String, sourceRect: CGRect, sourceView: UIView) {
        delegate?.shouldSendMessageWithText(text, sourceRect: sourceRect, sourceView: sourceView)
    }
}
