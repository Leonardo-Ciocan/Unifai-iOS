import Foundation
import SwiftyJSON

class CatalogItem {
    var name = ""
    var message = ""
    var description = ""
    var isSuitableForDashboard = false
    
    init(json:JSON){
        if let name = json["name"].string {
            self.name = name
        }
        
        if let message = json["message"].string {
            self.message = message
        }
        
        if let description = json["description"].string {
            self.description = description
        }
        
        if let isSuitableForDashboard = json["suitable_for_dashboard"].bool {
            self.isSuitableForDashboard = isSuitableForDashboard
        }
    }
}