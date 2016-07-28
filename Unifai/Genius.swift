import Foundation
import SwiftyJSON

struct GeniusGroup {
    var reason : String = ""
    var suggestions : [GeniusSuggestion] = []
    
    init(json:JSON) {
        if let reason = json["reason"].string {
            self.reason = reason
        }
        
        if let array = json["suggestions"].array {
            for item in array {
                suggestions.append(GeniusSuggestion(json: item))
            }
        }
    }
}

struct GeniusSuggestion {
    var name : String = ""
    var message : String = ""
    
    init(json:JSON) {
        if let name = json["name"].string {
            self.name = name
            if let message = json["message"].string {
                self.message = message
            }
        }
    }
}