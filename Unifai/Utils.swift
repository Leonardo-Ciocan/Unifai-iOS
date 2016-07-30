import Foundation
import UIKit

func matchesForRegexInText(regex: String!, text: String!) -> [String] {
    do {
        let regex = try NSRegularExpression(pattern: regex, options: [])
        let nsString = text as NSString
        let results = regex.matchesInString(text,
                                            options: [], range: NSMakeRange(0, nsString.length))
        return results.map { nsString.substringWithRange($0.range)}
    } catch let error as NSError {
        print("invalid regex: \(error.localizedDescription)")
        return []
    }
}

func extractServiceColorFrom(string:String) -> UIColor? {
    var target = matchesForRegexInText("(?:^|\\s|$|[.])@[\\p{L}0-9_]*", text: string)
    if(target.count > 0){
        let name = target[0]
        let services = Core.Services.filter({"@"+$0.username == name})
        if(services.count > 0){
            return services[0].color
        }
        else{
            return nil
        }
    }
    return nil
}


func extractService(string:String) -> Service? {
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

extension String {
    func extractLinks() -> [String]{
        let detector = try! NSDataDetector(types: NSTextCheckingType.Link.rawValue)
        let matches = detector.matchesInString(self, options: [], range: NSRange(location: 0, length: self.utf16.count))

        return matches.map({($0.URL?.absoluteString)!})
    }
}
