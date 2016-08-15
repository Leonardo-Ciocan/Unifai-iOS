import Foundation

class SheetEntry{
    func size() -> Int {
        switch self{
        case _ as TextSheetEntry:
            return 40
        case _ as ImageSheetEntry:
            return 70
        case _ as TitledSheetEntry:
            return 60
        case _ as ActionSheetEntry:
            return 40
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
    init(url:String) {
        self.url = url
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