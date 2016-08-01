import UIKit

class CatalogItemCell: UITableViewCell , ActionCreatorDelegate {

    @IBOutlet weak var imgAction: UIImageView!
    @IBOutlet weak var whiteView: UIView!
    @IBOutlet weak var txtText: UILabel!
    
    @IBOutlet weak var txtDescription: UILabel!
    var parentViewController : UIViewController?
    var item : CatalogItem?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let recon = UITapGestureRecognizer(target: self, action: #selector(imgActionTapped))
        imgAction.userInteractionEnabled = true
        imgAction.addGestureRecognizer(recon)
    }
    
    func imgActionTapped(){
        let actionCreator = ActionCreatorViewController()
        actionCreator.presetName = (item?.name)!
        actionCreator.presetMessage = (item?.message)!
        actionCreator.delegate = self
        parentViewController?.presentViewController(actionCreator, animated: true, completion: nil)
    }
    
    func createAction(name: String, message: String) {
        Unifai.createAction(message, name: name, completion: nil, error:nil)
        imgAction.hidden = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func didCreateAction() {
        
    }
    
    
}
