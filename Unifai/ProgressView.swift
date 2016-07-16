import UIKit

class ProgressView: UIView {
    
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var valueBackground: UIView!
    @IBOutlet weak var barView: UIView!
    @IBOutlet weak var progressBar: UIView!
    @IBOutlet weak var txtMax: UILabel!
    @IBOutlet weak var txtValue: UILabel!
    @IBOutlet weak var txtMin: UILabel!
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
        let nib = UINib(nibName: "ProgressView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.barView.layer.cornerRadius = 5
        self.barView.layer.masksToBounds = true
        valueBackground.layer.cornerRadius = 5
        valueBackground.layer.masksToBounds = true
        self.addSubview(view);
        view.backgroundColor = currentTheme.backgroundColor
        txtMax.textColor = currentTheme.foregroundColor
        txtMin.textColor = currentTheme.foregroundColor
        barView.backgroundColor = currentTheme.backgroundColor
    }
    
    func setProgressValues(min : Int , max : Int , value : Int){
        guard (max-min) != 0 && max != 0 else { return }
        let percentage = CGFloat(value-min) / CGFloat(max-min)
        
        progressBar.snp_makeConstraints(closure: { make in
            make.width.equalTo(progressBar.superview!).multipliedBy(percentage)
        })
        
        self.setNeedsLayout()
        
        txtMin.text = String(min)
        txtMax.text = String(max)
        txtValue.text = String(value)
    }
}
