import Foundation
import UIKit

class TextUtils {
    
    class func getPlaceholderPositionsInMessage(_ text:String) -> [NSRange] {
        do {
            let regex = try NSRegularExpression(pattern: "<[^<>]+>", options: [])
            let nsString = text as NSString
            let results = regex.matches(in: text,
                                                options: [], range: NSMakeRange(0, nsString.length))
            return results.map { $0.range }
        } catch _ as NSError {
            return []
        }
    }
    
    class func matchesForRegexInText(_ regex: String!, text: String!) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = text as NSString
            let results = regex.matches(in: text,
                                                options: [], range: NSMakeRange(0, nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    class func extractServiceColorFrom(_ string:String) -> UIColor? {
        if let service = TextUtils.extractService(string) {
            return service.color
        }
        else {
            return nil
        }
    }
    
    
    class func extractService(_ string:String) -> Service? {
        var target = matchesForRegexInText("(?:^|\\s|$|[.])@[\\p{L}0-9_]*", text: string)
        if(target.count > 0){
            let name = target[0]
            let services = Core.Services.filter({"@"+$0.username == name})
            if(services.count > 0){
                return services[0]
            }
            else{
                return nil
            }
        }
        return nil
    }
}

extension String {
    func extractLinks() -> [String]{
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))

        return matches.map({($0.url?.absoluteString)!})
    }
}
