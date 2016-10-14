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
        imgAction.isUserInteractionEnabled = true
        imgAction.addGestureRecognizer(recon)
    }
    
    func imgActionTapped(){
        let actionCreator = ActionCreatorViewController()
        actionCreator.presetName = (item?.name)!
        actionCreator.presetMessage = (item?.message)!
        actionCreator.delegate = self
        parentViewController?.present(actionCreator, animated: true, completion: nil)
    }
    
    func createAction(_ name: String, message: String) {
        Unifai.createAction(message, name: name, completion: nil, error:nil)
        imgAction.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func didCreateAction(_:  Action) {
        
    }
    
    
}
