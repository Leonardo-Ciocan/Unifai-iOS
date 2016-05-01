import Foundation
import Eureka

class NewActionController : FormViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section("New action")
            <<< TextRow("name"){
                $0.title = "Name"
                $0.value = ""
            }
            <<< TextRow("message"){
                $0.title = "Message"
                $0.value = ""
            }
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(doneClick))
    }
    
    func doneClick(sender:UIBarButtonItem){
        let message = self.form.values(includeHidden: true)["message"] as! String
        let name = self.form.values(includeHidden: true)["name"] as! String
        
        Unifai.createAction(message, name: name, completion:{_ in self.dismissViewControllerAnimated(true, completion: nil)})
    }
}