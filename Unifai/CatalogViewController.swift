//
//  CatalogViewController.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 05/07/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

class CatalogViewController : UIViewController , UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    @IBOutlet weak var pageControl: UIPageControl!
    var lastColor = UIColor.clearColor()
    var serivices : [Service] = []
    
    @IBAction func doneTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.registerNib(UINib(nibName: "CatalogCell", bundle: nil), forCellWithReuseIdentifier: "CatalogCell")
        
        self.serivices = Core.Services.sort({ $0.name < $1.name }) //.filter({ $0.id != "1989" })
        pageControl.numberOfPages = self.serivices.count - 1
        
        
        collectionView.delegate = self
        collectionView.dataSource = self
        //self.tabBarController?.tabBar.tintColor = UIColor.whiteColor()
        self.tabBarController?.tabBar.tintColor  = serivices[0].color
        self.navigationController?.navigationBar.barTintColor = serivices[0].color
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        lastColor = serivices[0].color
        collectionView.allowsSelection = false
        navigationController?.navigationBar.barStyle = .Black
        
        (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).minimumInteritemSpacing = 0
        (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = UIScreen.mainScreen().bounds.size
        
        
        self.navigationController?.navigationBar.barTintColor = serivices[0].color
        self.collectionView.backgroundColor = UIColor.whiteColor()
    }

    
    override func viewDidAppear(animated: Bool) {

        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return serivices.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CatalogCell", forIndexPath: indexPath) as! CatalogCell
        cell.loadData(self.serivices[indexPath.row])
        cell.parentViewController = self
        return cell
    }
            
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return self.collectionView.frame.size
    }
    
    func xxscrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let pos = Int(floor(collectionView.contentOffset.x / (collectionView.contentSize.width-collectionView.frame.width) * CGFloat(serivices.count-1)))
        //print("\(scrollView.contentOffset.x) out of \(scrollView.contentSize.width-collectionView.frame.width)")
        //let pos = collectionView.indexPathsForVisibleItems().sort({ $0.row > $1.row}).first
        //        if let cell = self.collectionView.cellForItemAtIndexPath(pos){
        //            let c = serivices[collectionView.indexPathForCell(cell)!.row]
        //            self.navigationController?.navigationBar.barTintColor = c.color
        //            self.tabBarController?.tabBar.barTintColor = c.color
        //        }
        let c = serivices[pos]
        //        UIView.animateWithDuration(1, animations: {
        //            self.navigationController?.navigationBar.barTintColor = c.color
        //            self.tabBarController?.tabBar.barTintColor = c.color
        //            self.collectionView.backgroundColor = c.color
        //        })
        lastColor = c.color
        self.navigationController?.navigationBar.barTintColor = c.color
        self.tabBarController?.tabBar.tintColor  = c.color
        //self.collectionView.backgroundColor = c.color
        
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        //let percentage = collectionView.contentOffset.x / (collectionView.contentSize.width-collectionView.frame.width)
        let pos = Int(floor((collectionView.contentOffset.x / self.view.frame.width)))
        if pos == serivices.count-1
        {
            return
        }
        //print("\(pos)-\(pos+1)")
        let c = serivices[pos+1]
        let col = self.fadeFromColor(serivices[pos].color, toColor: c.color, withPercentage: (collectionView.contentOffset.x % self.view.frame.width) / (self.view.frame.width))
        pageControl.currentPage = pos
        
        self.navigationController?.navigationBar.barTintColor = col
        self.tabBarController?.tabBar.tintColor = col
        //self.collectionView.backgroundColor = col
    }
    
    func fadeFromColor(fromColor: UIColor, toColor: UIColor, withPercentage: CGFloat) -> UIColor {
        
        var fromRed: CGFloat = 0.0
        var fromGreen: CGFloat = 0.0
        var fromBlue: CGFloat = 0.0
        var fromAlpha: CGFloat = 0.0
        
        fromColor.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: &fromAlpha)
        
        var toRed: CGFloat = 0.0
        var toGreen: CGFloat = 0.0
        var toBlue: CGFloat = 0.0
        var toAlpha: CGFloat = 0.0
        
        toColor.getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: &toAlpha)
        
        //calculate the actual RGBA values of the fade colour
        let red = (toRed - fromRed) * withPercentage + fromRed;
        let green = (toGreen - fromGreen) * withPercentage + fromGreen;
        let blue = (toBlue - fromBlue) * withPercentage + fromBlue;
        let alpha = (toAlpha - fromAlpha) * withPercentage + fromAlpha;
        
        // return the fade colour
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }

}
