import Foundation
import UIKit
import SwiftyJSON

class Action{
    var message : String = ""
    var name : String = ""
    var id : String = ""
    
    init(json:JSON){
        print(json)
        if let message = json["message"].string {
            self.message = message
        }
        if let name = json["name"].string {
            self.name = name
        }
        if let id = json["id"].int {
            self.id = String(id)
        }
    }
    
}