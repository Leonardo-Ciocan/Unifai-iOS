//
//  CatalogViewController.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 05/07/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

class CatalogViewController : UIViewController , UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    let pageControl: UIPageControl  = UIPageControl()
    var lastColor = UIColor.clear
    var serivices : [Service] = []
    
    @IBAction func doneTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.register(UINib(nibName: "CatalogCell", bundle: nil), forCellWithReuseIdentifier: "CatalogCell")
        
        self.serivices = Core.Services.sorted(by: { $0.name < $1.name }) //.filter({ $0.id != "1989" })
        
        
        pageControl.numberOfPages = self.serivices.count - 1
        self.navigationItem.titleView = pageControl
        let invisibleButton = UIBarButtonItem(title: "Done", style: .done, target: nil, action: nil)
        invisibleButton.tintColor = UIColor.clear
        self.navigationItem.leftBarButtonItem = invisibleButton
        
        collectionView.delegate = self
        collectionView.dataSource = self
        //self.tabBarController?.tabBar.tintColor = UIColor.whiteColor()
        self.tabBarController?.tabBar.tintColor  = serivices[0].color
        self.navigationController?.navigationBar.barTintColor = serivices[0].color
        self.navigationController?.navigationBar.tintColor = UIColor.white
        lastColor = serivices[0].color
        collectionView.allowsSelection = false
        navigationController?.navigationBar.barStyle = .black
        
        (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).minimumInteritemSpacing = 0
        (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = UIScreen.main.bounds.size
        
        
        self.navigationController?.navigationBar.barTintColor = serivices[0].color
        self.collectionView.backgroundColor = UIColor.white
    }

    
    override func viewDidAppear(_ animated: Bool) {

        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return serivices.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CatalogCell", for: indexPath) as! CatalogCell
        cell.loadData(self.serivices[(indexPath as NSIndexPath).row])
        cell.parentViewController = self
        return cell
    }
            
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return self.collectionView.frame.size
    }
    
    func xxscrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
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
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //let percentage = collectionView.contentOffset.x / (collectionView.contentSize.width-collectionView.frame.width)
        let pos = Int(floor((collectionView.contentOffset.x / self.view.frame.width)))
        if pos == serivices.count-1
        {
            return
        }
        //print("\(pos)-\(pos+1)")
        let c = serivices[pos+1]
        let col = self.fadeFromColor(serivices[pos].color, toColor: c.color, withPercentage: (collectionView.contentOffset.x.truncatingRemainder(dividingBy: self.view.frame.width)) / (self.view.frame.width))
        pageControl.currentPage = pos
        
        self.navigationController?.navigationBar.barTintColor = col
        self.tabBarController?.tabBar.tintColor = col
        //self.collectionView.backgroundColor = col
    }
    
    func fadeFromColor(_ fromColor: UIColor, toColor: UIColor, withPercentage: CGFloat) -> UIColor {
        
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

}
