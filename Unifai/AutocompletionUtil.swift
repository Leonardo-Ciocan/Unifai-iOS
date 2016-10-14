import Foundation

struct AutocompletionState {
    let service : String
    let keywords : [String]
}

class Autocomplete {
    class func computeState(fromText query : String) ->  AutocompletionState {
        let text = query.replacingOccurrences(of: "@", with: "")
        if text.characters.count == 0 {
            return AutocompletionState(service: "", keywords: [])
        }
        else if !text.characters.contains(" ") {
            return AutocompletionState(service: text, keywords: [])
        }
        else {
            let parts = text.components(separatedBy: " ")
            let service = parts[0]
            let keywords = Array(parts[1..<parts.count])
            return AutocompletionState(service: service, keywords: keywords)
        }
    }
}

