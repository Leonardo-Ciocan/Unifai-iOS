import Foundation
import Regex

extension String {
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet()
        )
    }
}

enum FilterType {
    case StartsWith(key:String, value : String )
    case Contains(key:String, value : String )
    case MoreThan(key:String, value:Int)
    case LessThan(key:String, value:Int)
    case Between(from : Int, to : Int)
    case None
    
    static func fromText(text:String) -> FilterType {
        let startsWithResult = "(.+) is (.+)".r!.findFirst(in: text)
        if let startsWithResult = startsWithResult {
            if startsWithResult.subgroups.count == 2 {
                return .StartsWith(key:startsWithResult.group(at: 1)!.trim(), value:startsWithResult.group(at: 2)!.trim())
            }
        }
        
        let containsResult = "(.+) contains (.+)".r!.findFirst(in: text)
        if let containsResult = containsResult {
            if containsResult.subgroups.count == 2 {
                return .Contains(key:containsResult.group(at: 1)!.trim(), value:containsResult.group(at: 2)!.trim())
            }
        }
        
        let moreThanResult = "more than (\\d+\\.?\\d*)\\s(.+)".r!.findFirst(in: text)
        if let moreThanResult = moreThanResult {
            if let numberGroup = moreThanResult.group(at: 1) {
                if let keyGroup = moreThanResult.group(at: 2) {
                    if let value = Int(numberGroup) {
                        return .MoreThan(key:keyGroup.trim(), value: value)
                    }
                }
            }
        }
        
        let lessThanResult = "more than (\\d+\\.?\\d*)\\s(.+)".r!.findFirst(in: text)
        if let lessThanResult = lessThanResult {
            if let numberGroup = lessThanResult.group(at: 1) {
                if let keyGroup = lessThanResult.group(at: 2) {
                    if let value = Int(numberGroup) {
                        return .LessThan(key:keyGroup.trim(), value: value)
                    }
                }
            }
        }
        
        return .None
    }
    
    var rawValue : Int {
        get {
            switch self {
            case .None(info: _) : return 0
            default : return 1
            }
        }
    }
}

func ==(lhs:FilterType, rhs:FilterType) -> Bool {
    
    return (lhs.rawValue == rhs.rawValue)
    
}