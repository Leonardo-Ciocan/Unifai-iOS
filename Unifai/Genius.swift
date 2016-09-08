import Foundation
import SwiftyJSON
import UIKit

struct GeniusGroup {
    var reason : String = ""
    var suggestions : [GeniusSuggestion] = []

    static func fromJSON(json:JSON) -> GeniusGroup? {
        guard let reason = json["reason"].string  else { return nil }
        guard let array = json["suggestions"].array else { return nil }
        return GeniusGroup(reason: reason, suggestions: array.map({GeniusSuggestion.fromJSON($0)!}))
    }
}

enum GeniusTriggerType {
    case SendMessage
    case PasteImage
    case OpenLink
}

struct GeniusSuggestion {
    var name : String = ""
    var message : String = ""
    var trigger : GeniusTriggerType = .SendMessage

    static func fromJSON(json:JSON) -> GeniusSuggestion? {
        guard let name = json["name"].string  else { return nil }
        guard let message = json["message"].string  else { return nil }

        return GeniusSuggestion(name: name, message: message, trigger: .SendMessage)
    }
}

class GeniusUtil {
    class func performQRCodeDetection(image: CIImage) ->  String {
        var decode = ""
        let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: options)
        let features = detector.featuresInImage(image)
        for feature in features as! [CIQRCodeFeature] {
            decode = feature.messageString
        }
        return decode
    }
}

class Genius {
    class func computeLocalGeniusSuggestions(withImageData image : NSData?) -> [GeniusGroup] {
        let clipboardSuggestions = Genius.getSuggestionsForClipboard()
        let imageSuggestions = getSuggestionsForImage(image)
        return clipboardSuggestions + imageSuggestions
    }

    class func getSuggestionsForImage(image:NSData?) -> [GeniusGroup] {
        guard let image = image,
              let img = CIImage(data: image)
            else { return [] }
        let str = GeniusUtil.performQRCodeDetection(img)
        if !str.isEmpty {
            let group = GeniusGroup(reason: "Because your image contains a QR code", suggestions: [
                    GeniusSuggestion(name: "Open in browser", message: str, trigger: .OpenLink)
                ])
            return [group]
        }
        return []
    }
    
    class func getSuggestionsForClipboard() -> [GeniusGroup] {
        var groups : [GeniusGroup] = []
        if let clipboardText = UIPasteboard.generalPasteboard().string {
            let urls = clipboardText.extractLinks()
            if urls.count > 0 {
                var group = GeniusGroup(
                    reason : "Because you have a link in your clipboard",
                    suggestions : urls.map({
                        GeniusSuggestion(name: "Shorten link", message: "@web shorten " + $0 , trigger: .SendMessage)
                    }))
                group.suggestions.appendContentsOf(urls.map({
                    GeniusSuggestion(name: "Open link in browser", message: $0 , trigger: .OpenLink)
                }))
                groups.append(group)
            }
        }
        else if let clipboardImage = UIPasteboard.generalPasteboard().image {
            let group = GeniusGroup(
                reason : "Because you copied an image",
                suggestions : [
                    GeniusSuggestion(name: "Use image as attachment", message: "\(Int(clipboardImage.size.width))x\(Int(clipboardImage.size.height))" , trigger: .PasteImage)
                ])
            groups.append(group)
            
            guard
                let img = CIImage(data: UIImagePNGRepresentation(clipboardImage)!)
                else { return [] }
            let str = GeniusUtil.performQRCodeDetection(img)
            if !str.isEmpty {
                let group = GeniusGroup(reason: "Because the image you copied contains a QR code", suggestions: [
                    GeniusSuggestion(name: "Open in browser", message: str, trigger: .OpenLink)
                    ])
                return [group]
            }
            return []
        }
        return groups
    }
}