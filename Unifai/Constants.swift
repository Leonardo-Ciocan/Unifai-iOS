import Foundation
import UIKit

class Constants{
    static let appBrandColor = UIColor(red: 0.741, green: 0.404, blue: 0.878, alpha: 1.00)
    
    static let urlRoot           = "http://127.0.0.1:8000/" //"http://13.92.246.125:1989/"
    static let urlThread         = urlRoot + "thread/"
    static let urlFeed           = urlRoot + "feed/"
    static let urlLogin          = urlRoot + "api-token-auth/"
    static let urlServices       = urlRoot + "services/all/"
    static let urlMessage        = urlRoot + "message/"
    static let urlServiceProfile = urlRoot + "service/"
    static let urlUserProfile    = urlRoot + "user/"
    static let urlUserInfo       = urlRoot + "me/"
    static let urlSchedules      = urlRoot + "trigger/"
    static let urlSignup         = urlRoot + "signup/"
    static let urlAction         = urlRoot + "action/"
    static let urlDashboard      = urlRoot + "dashboard/"
    static let urlDashboardItems = urlRoot + "dashboard/items/"
    static let urlAuthCode = urlRoot + "auth-code/"

}