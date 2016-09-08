import UIKit

protocol AutoCompletionServicesDelegate {
    func selectedService(service:Service, selectedByTapping : Bool)
    func shouldHideServiceAutocompletion()
    func shouldDismiss()
}

extension UIView
{
    func addCornerRadiusAnimation(from: CGFloat, to: CGFloat, duration: CFTimeInterval)
    {
        let animation = CABasicAnimation(keyPath:"cornerRadius")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.fromValue = from
        animation.toValue = to
        animation.duration = duration
        self.layer.addAnimation(animation, forKey: "cornerRadius")
        self.layer.cornerRadius = to
    }
}

class AutoCompletionServices: UIView , UICollectionViewDelegateFlowLayout , UICollectionViewDataSource {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var filterText : String = ""
    var delegate : AutoCompletionServicesDelegate?
    var overlayView : UIView?
    
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
        let nib = UINib(nibName: "AutoCompletionServices", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        view.backgroundColor = currentTheme.backgroundColor
        self.backgroundColor = currentTheme.backgroundColor
        
        self.addSubview(view);
        
        collectionView.registerNib(UINib(nibName: "AutoCompletionServiceCell",bundle: nil), forCellWithReuseIdentifier: "ServiceCell")
        
        self.overlayView = UIView()
        self.overlayView?.hidden = true
        self.overlayView!.layer.masksToBounds = true
        self.addSubview(overlayView!)
    }
    
    override func didMoveToSuperview() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ServiceCell", forIndexPath: indexPath) as! AutoCompletionServiceCell
        let index = indexPath.row
        if index == 0 {
            cell.txtName.text = "Dismiss"
            cell.txtName.textColor = UIColor.grayColor()
            cell.backgroundColorView.backgroundColor = currentTheme.backgroundColor
            cell.backgroundColorView.layer.borderColor = UIColor.grayColor().CGColor
            cell.backgroundColorView.layer.borderWidth = 1
            cell.imgLogo.image = UIImage(named: "cancel")
            cell.imgLogo.tintColor = UIColor.grayColor()
        }
        else {
            cell.loadService(getServices()[index - 1])
            cell.backgroundColorView.layer.borderWidth = 0
        }
        cell.backgroundColorView.layer.cornerRadius = (self.collectionView.frame.width / 4 - 30) / 2
        return cell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getServices().count + 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = self.collectionView.frame
        return CGSize(width: size.width/4, height: size.width/4 + 25)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            delegate?.shouldDismiss()
            return
        }
        
        self.delegate?.selectedService(getServices()[indexPath.row - 1] , selectedByTapping: true)
        let cellFrame = collectionView.layoutAttributesForItemAtIndexPath(indexPath)?.frame
        let logoFrame = CGRect(x: (cellFrame?.origin.x)! + 15, y: (cellFrame?.origin.y)! + 15 , width: (cellFrame?.size.width)! - 30, height: (cellFrame?.size.width)! - 30)
        overlayView?.layer.cornerRadius = (UIScreen.mainScreen().bounds.width / 4 - 30)/2
        overlayView?.frame = logoFrame
        overlayView?.hidden = false
        let service = getServices()[indexPath.row - 1]
        overlayView?.backgroundColor = service.color
        overlayView?.addCornerRadiusAnimation(overlayView!.layer.cornerRadius, to: 0, duration: 0.6)
        UIView.animateWithDuration(0.45,delay:0,options: UIViewAnimationOptions.CurveEaseIn,
                                   animations: {
            self.overlayView?.frame = self.frame
            //self.overlayView?.backgroundColor = service.color.darkenColor(0.25)
            //self.overlayView?.layer.cornerRadius = 0
            self.collectionView.alpha = 0
            } ,completion: {
                _ in
                self.delegate?.shouldHideServiceAutocompletion()
                self.overlayView?.hidden = true
                self.collectionView.alpha = 1
        })
    }
    
    func getServices() -> [Service] {
        return filterText.isEmpty ? Core.Services : Core.Services.filter({$0.name.lowercaseString.hasPrefix(filterText)})
    }
    
    func filterServices(text:String){
        self.filterText = text
        self.collectionView.reloadData()
    }
    


}
