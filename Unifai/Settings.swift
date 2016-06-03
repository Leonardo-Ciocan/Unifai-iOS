import Foundation
import UIKit

class Settings {
    
    static var onlyTextOnFeed : Bool = false
    static var textSize : Int = 1
    static var cardSize : Int = 1
    static var startingPage :Int = 0
    
    static func setup(){
        
        let url = NSBundle.mainBundle().URLForResource("DefaultSettings", withExtension: "plist")
        let prefs : [String:AnyObject] = NSDictionary(contentsOfURL: url!)! as! [String : AnyObject]
        NSUserDefaults.standardUserDefaults().registerDefaults(prefs)
        
        onlyTextOnFeed = NSUserDefaults.standardUserDefaults().boolForKey("onlyTextOnFeed")
        textSize = NSUserDefaults.standardUserDefaults().integerForKey("textSize")
        cardSize = NSUserDefaults.standardUserDefaults().integerForKey("cardSize")
        startingPage = NSUserDefaults.standardUserDefaults().integerForKey("startingPage")
    }
    
}