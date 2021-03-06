import UIKit

class ActionCell: UICollectionViewCell {
    @IBOutlet weak var editView : UIVisualEffectView!
    @IBOutlet weak var blur: UIVisualEffectView!
    @IBOutlet weak var txtName: UILabel!
    @IBOutlet weak var txtMessage: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        layer.masksToBounds = false
//        layer.shadowColor = UIColor.blackColor().CGColor
//        layer.shadowOpacity = 0.12
//        layer.shadowOffset = CGSizeZero
//        layer.shadowRadius = 5
    }
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    
    var actionsViewController : ActionsViewController?
    
    var action : Action?
    func loadData(_ action:Action){
        self.action = action
        txtName.text = action.name
        let service = TextUtils.extractService(action.message)!
        self.backgroundColor = service.color
        txtName.textColor = UIColor.white
    }
    
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    
    func deleteAction(){
        Unifai.deleteAction(action!.id, completion: { _ in
            let service = TextUtils.extractService((self.action?.message)!)
            self.actionsViewController?.actions[service!]  = (self.actionsViewController?.actions[service!]!.filter{ $0.id != self.action!.id })!
            self.actionsViewController?.collectionView.reloadData()
        })
    }
    
}
