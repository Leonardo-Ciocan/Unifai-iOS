import Foundation
import UIKit
import SwiftyJSON

func ==(lhs: Service, rhs: Service) -> Bool {
    return lhs.id == rhs.id
}

class Service : Hashable {
    var name : String
    var color : UIColor
    var id : String?

    var username : String {
        get{
            return name.lowercaseString
        }
    }
    
    init(name:String , color:UIColor){
        self.name = name
        self.color = color
    }
    
    init(json:JSON){
        let id = json["id"].number?.stringValue
        let name = json["name"].string
        let color = json["colour"].string?.componentsSeparatedByString(",").map{ str in Int(str)}
        
        self.id = id
        self.name = name!
        self.color = UIColor(red: CGFloat(color![0]!) / 255.0,
                             green: CGFloat(color![1]!) / 255.0,
                             blue: CGFloat(color![2]!) / 255.0,
                             alpha: 255)
    }
    
    var hashValue: Int {
        get {
            return (id?.hashValue)!
        }
    }
}
