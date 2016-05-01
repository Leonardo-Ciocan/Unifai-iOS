import Foundation
import UIKit
import SwiftyJSON

class Action{
    var message : String
    var name : String
    
    init(json:JSON){
        let message = json["message"].stringValue
        let name = json["name"].stringValue
        
        self.message = message
        self.name = name
    }
}