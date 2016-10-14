import Foundation
import SwiftyJSON
import UIKit

struct GeniusGroup {
    var reason : String = ""
    var suggestions : [GeniusSuggestion] = []

    static func fromJSON(_ json:JSON) -> GeniusGroup? {
        guard let reason = json["reason"].string  else { return nil }
        guard let array = json["suggestions"].array else { return nil }
        return GeniusGroup(reason: reason, suggestions: array.map({GeniusSuggestion.fromJSON($0)!}))
    }
}

enum GeniusTriggerType {
    case sendMessage
    case pasteImage
    case openLink
}

struct GeniusSuggestion {
    var name : String = ""
    var message : String = ""
    var trigger : GeniusTriggerType = .sendMessage

    static func fromJSON(_ json:JSON) -> GeniusSuggestion? {
        guard let name = json["name"].string  else { return nil }
        guard let message = json["message"].string  else { return nil }

        return GeniusSuggestion(name: name, message: message, trigger: .SendMessage)
    }
}

class GeniusUtil {
    class func performQRCodeDetection(_ image: CIImage) ->  String {
        var decode = ""
        let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: options)
        let features = detector?.features(in: image)
        for feature in features as! [CIQRCodeFeature] {
            decode = feature.messageString!
        }
        return decode
    }
}

class Genius {
    class func computeLocalGeniusSuggestions(withImageData image : Data?) -> [GeniusGroup] {
        let clipboardSuggestions = Genius.getSuggestionsForClipboard()
        let imageSuggestions = getSuggestionsForImage(image)
        return clipboardSuggestions + imageSuggestions
    }

    class func getSuggestionsForImage(_ image:Data?) -> [GeniusGroup] {
        guard let image = image,
              let img = CIImage(data: image)
            else { return [] }
        let str = GeniusUtil.performQRCodeDetection(img)
        if !str.isEmpty {
            let group = GeniusGroup(reason: "Because your image contains a QR code", suggestions: [
                    GeniusSuggestion(name: "Open in browser", message: str, trigger: .openLink)
                ])
            return [group]
        }
        return []
    }
    
    class func getSuggestionsForClipboard() -> [GeniusGroup] {
        var groups : [GeniusGroup] = []
        if let clipboardText = UIPasteboard.general.string {
            let urls = clipboardText.extractLinks()
            if urls.count > 0 {
                var group = GeniusGroup(
                    reason : "Because you have a link in your clipboard",
                    suggestions : urls.map({
                        GeniusSuggestion(name: "Shorten link", message: "@web shorten " + $0 , trigger: .sendMessage)
                    }))
                group.suggestions.append(contentsOf: urls.map({
                    GeniusSuggestion(name: "Open link in browser", message: $0 , trigger: .openLink)
                }))
                groups.append(group)
            }
        }
        else if let clipboardImage = UIPasteboard.general.image {
            let group = GeniusGroup(
                reason : "Because you copied an image",
                suggestions : [
                    GeniusSuggestion(name: "Use image as attachment", message: "\(Int(clipboardImage.size.width))x\(Int(clipboardImage.size.height))" , trigger: .pasteImage)
                ])
            groups.append(group)
            
            guard
                let img = CIImage(data: UIImagePNGRepresentation(clipboardImage)!)
                else { return [] }
            let str = GeniusUtil.performQRCodeDetection(img)
            if !str.isEmpty {
                let group = GeniusGroup(reason: "Because the image you copied contains a QR code", suggestions: [
                    GeniusSuggestion(name: "Open in browser", message: str, trigger: .openLink)
                    ])
                return [group]
            }
            return []
        }
        return groups
    }
}
