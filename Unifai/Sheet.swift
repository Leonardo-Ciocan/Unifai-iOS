import Foundation

class SheetEntry{
    func size() -> Int {
        switch self{
        case _ as TextSheetEntry:
            return 40
        case _ as TitledSheetEntry:
            return 50
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
    init(label:String, action:String){
        self.label = label
        self.action = action
    }
}
class TextSheetEntry : SheetEntry {
    var text = ""
    init(text:String) {
        self.text = text
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