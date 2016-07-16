import Foundation
import UIKit

var currentTheme : Theme = DarkTheme()

protocol Theme {
    var backgroundColor : UIColor { get }
    var foregroundColor : UIColor { get }
    var shadeColor : UIColor { get }
    var secondaryForegroundColor : UIColor { get }
    var barStyle : UIBarStyle { get }
    var statusBarStyle : UIStatusBarStyle { get }
}

class LightTheme : Theme {
    var backgroundColor: UIColor = UIColor.whiteColor()
    var foregroundColor: UIColor = UIColor.blackColor()
    var secondaryForegroundColor: UIColor = UIColor(red: 0.549, green: 0.549, blue: 0.549, alpha: 1.0)
    var shadeColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05)
    var barStyle: UIBarStyle = .Default
    var statusBarStyle: UIStatusBarStyle = .Default
}

class DarkTheme : Theme {
    var backgroundColor: UIColor = UIColor(red: 0.1176, green: 0.1176, blue: 0.1176, alpha: 1.0)
    var secondaryForegroundColor: UIColor = UIColor(red: 0.549, green: 0.549, blue: 0.549, alpha: 1.0)
    var foregroundColor: UIColor = UIColor.whiteColor()
    var shadeColor: UIColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.05)
    var barStyle: UIBarStyle = .Black
    var statusBarStyle: UIStatusBarStyle = .LightContent
}