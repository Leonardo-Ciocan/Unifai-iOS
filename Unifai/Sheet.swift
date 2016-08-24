import Foundation

class SheetEntry{
    func size() -> Int {
        switch self{
        case _ as TextSheetEntry:
            return 40
        case _ as ImageSheetEntry:
            return 200
        case _ as TitledSheetEntry:
            return 60
        case _ as ActionSheetEntry:
            return 50
        default:
            return 0
        }
    }
}

class ActionSheetEntry : SheetEntry {
    var label = ""
    var action = ""
    var value = ""
    init(label:String, action:String, value:String){
        self.label = label
        self.action = action
        self.value = value
    }
}
class TextSheetEntry : SheetEntry {
    var text = ""
    init(text:String) {
        self.text = text
    }
}
class ImageSheetEntry : SheetEntry {
    var url = ""
    var title = ""
    var link = ""
    init(url:String, title:String, link:String) {
        self.url = url
        self.title = title
        self.link = link
    }
}
class TitledSheetEntry : SheetEntry {
    var title = ""
    var subtitle = ""
    
    init(title:String, subtitle:String) {
        self.title = title
        self.subtitle = subtitle
    }
}

class Sheet {
    var entries : [SheetEntry] = []
}