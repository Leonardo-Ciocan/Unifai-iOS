import Foundation

extension String {
    func trim() -> String {
        return self.trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines
        )
    }
}

enum FilterType {
    case startsWith(key:String, value : String )
    case contains(key:String, value : String )
    case moreThan(key:String, value:Int)
    case lessThan(key:String, value:Int)
    case between(from : Int, to : Int)
    case none
    
    static func fromText(_ text:String) -> FilterType {
        // TODO reimplement this
//        let startsWithResult = "(.+) is (.+)".r!.findFirst(in: text)
//        if let startsWithResult = startsWithResult {
//            if startsWithResult.subgroups.count == 2 {
//                return .StartsWith(key:startsWithResult.group(at: 1)!.trim(), value:startsWithResult.group(at: 2)!.trim())
//            }
//        }
//        
//        let containsResult = "(.+) contains (.+)".r!.findFirst(in: text)
//        if let containsResult = containsResult {
//            if containsResult.subgroups.count == 2 {
//                return .Contains(key:containsResult.group(at: 1)!.trim(), value:containsResult.group(at: 2)!.trim())
//            }
//        }
//        
//        let moreThanResult = "more than (\\d+\\.?\\d*)\\s(.+)".r!.findFirst(in: text)
//        if let moreThanResult = moreThanResult {
//            if let numberGroup = moreThanResult.group(at: 1) {
//                if let keyGroup = moreThanResult.group(at: 2) {
//                    if let value = Int(numberGroup) {
//                        return .MoreThan(key:keyGroup.trim(), value: value)
//                    }
//                }
//            }
//        }
//        
//        let lessThanResult = "more than (\\d+\\.?\\d*)\\s(.+)".r!.findFirst(in: text)
//        if let lessThanResult = lessThanResult {
//            if let numberGroup = lessThanResult.group(at: 1) {
//                if let keyGroup = lessThanResult.group(at: 2) {
//                    if let value = Int(numberGroup) {
//                        return .LessThan(key:keyGroup.trim(), value: value)
//                    }
//                }
//            }
//        }
        
        return .none
    }
    
    var rawValue : Int {
        get {
            switch self {
            case .none(info: _) : return 0
            default : return 1
            }
        }
    }
}

func ==(lhs:FilterType, rhs:FilterType) -> Bool {
    
    return (lhs.rawValue == rhs.rawValue)
    
}
