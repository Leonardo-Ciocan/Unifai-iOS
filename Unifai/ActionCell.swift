import UIKit

class ActionCell: UICollectionViewCell {
    @IBOutlet weak var editView : UIVisualEffectView!
    @IBOutlet weak var blur: UIVisualEffectView!
    @IBOutlet weak var txtName: UILabel!
    @IBOutlet weak var txtMessage: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    
    var actionsViewController : ActionsViewController?
    
    var action : Action?
    func loadData(action:Action){
        self.action = action
        txtName.text = action.name.uppercaseString
        let service = extractService(action.message)!
        self.backgroundColor = service.color
        txtName.textColor = UIColor.whiteColor()
    }
    
    
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
    }
    
    
    func deleteAction(){
        Unifai.deleteAction(action!.id, completion: { _ in
            let service = extractService((self.action?.message)!)
            self.actionsViewController?.actions[service!]  = (self.actionsViewController?.actions[service!]!.filter{ $0.id != self.action!.id })!
            self.actionsViewController?.collectionView.reloadData()
        })
    }
    
}
