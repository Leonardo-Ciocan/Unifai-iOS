import Foundation
import UIKit

class Settings {
    
    static var onlyTextOnFeed : Bool = false
    static var textSize : Int = 1
    static var cardSize : Int = 1
    static var startingPage :Int = 0
    static var darkTheme : Bool = false
    
    static func setup(){
        
        let url = Bundle.main.url(forResource: "DefaultSettings", withExtension: "plist")
        let prefs : [String:AnyObject] = NSDictionary(contentsOf: url!)! as! [String : AnyObject]
        UserDefaults.standard.register(defaults: prefs)
        
        onlyTextOnFeed = UserDefaults.standard.bool(forKey: "onlyTextOnFeed")
        darkTheme = UserDefaults.standard.bool(forKey: "darkTheme")
        textSize = UserDefaults.standard.integer(forKey: "textSize")
        cardSize = UserDefaults.standard.integer(forKey: "cardSize")
        startingPage = UserDefaults.standard.integer(forKey: "startingPage")
        
        currentTheme = darkTheme ? DarkTheme() : LightTheme()
    }
    
}
