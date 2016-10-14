import UIKit

protocol AutoCompletionServicesDelegate {
    func selectedService(_ service:Service, selectedByTapping : Bool)
    func shouldHideServiceAutocompletion()
    func shouldDismiss()
}

extension UIView
{
    func addCornerRadiusAnimation(_ from: CGFloat, to: CGFloat, duration: CFTimeInterval)
    {
        let animation = CABasicAnimation(keyPath:"cornerRadius")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.fromValue = from
        animation.toValue = to
        animation.duration = duration
        self.layer.add(animation, forKey: "cornerRadius")
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
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "AutoCompletionServices", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.backgroundColor = currentTheme.backgroundColor
        self.backgroundColor = currentTheme.backgroundColor
        
        self.addSubview(view);
        
        collectionView.register(UINib(nibName: "AutoCompletionServiceCell",bundle: nil), forCellWithReuseIdentifier: "ServiceCell")
        
        self.overlayView = UIView()
        self.overlayView?.isHidden = true
        self.overlayView!.layer.masksToBounds = true
        self.addSubview(overlayView!)
    }
    
    override func didMoveToSuperview() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ServiceCell", for: indexPath) as! AutoCompletionServiceCell
        let index = (indexPath as NSIndexPath).row
        if index == 0 {
            cell.txtName.text = "Dismiss"
            cell.txtName.textColor = UIColor.gray
            cell.backgroundColorView.backgroundColor = currentTheme.backgroundColor
            cell.backgroundColorView.layer.borderColor = UIColor.gray.cgColor
            cell.backgroundColorView.layer.borderWidth = 1
            cell.imgLogo.image = UIImage(named: "cancel")
            cell.imgLogo.tintColor = UIColor.gray
        }
        else {
            cell.loadService(getServices()[index - 1])
            cell.backgroundColorView.layer.borderWidth = 0
        }
        cell.backgroundColorView.layer.cornerRadius = (self.collectionView.frame.width / 4 - 30) / 2
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getServices().count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = self.collectionView.frame
        return CGSize(width: size.width/4, height: size.width/4 + 25)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row == 0 {
            delegate?.shouldDismiss()
            return
        }
        
        self.delegate?.selectedService(getServices()[(indexPath as NSIndexPath).row - 1] , selectedByTapping: true)
        let cellFrame = collectionView.layoutAttributesForItem(at: indexPath)?.frame
        let logoFrame = CGRect(x: (cellFrame?.origin.x)! + 15, y: (cellFrame?.origin.y)! + 15 , width: (cellFrame?.size.width)! - 30, height: (cellFrame?.size.width)! - 30)
        overlayView?.layer.cornerRadius = (UIScreen.main.bounds.width / 4 - 30)/2
        overlayView?.frame = logoFrame
        overlayView?.isHidden = false
        let service = getServices()[(indexPath as NSIndexPath).row - 1]
        overlayView?.backgroundColor = service.color
        overlayView?.addCornerRadiusAnimation(overlayView!.layer.cornerRadius, to: 0, duration: 0.6)
        UIView.animate(withDuration: 0.45,delay:0,options: UIViewAnimationOptions.curveEaseIn,
                                   animations: {
            self.overlayView?.frame = self.frame
            //self.overlayView?.backgroundColor = service.color.darkenColor(0.25)
            //self.overlayView?.layer.cornerRadius = 0
            self.collectionView.alpha = 0
            } ,completion: {
                _ in
                self.delegate?.shouldHideServiceAutocompletion()
                self.overlayView?.isHidden = true
                self.collectionView.alpha = 1
        })
    }
    
    func getServices() -> [Service] {
        return filterText.isEmpty ? Core.Services : Core.Services.filter({$0.name.lowercased().hasPrefix(filterText)})
    }
    
    func filterServices(_ text:String){
        self.filterText = text
        self.collectionView.reloadData()
    }
    


}
