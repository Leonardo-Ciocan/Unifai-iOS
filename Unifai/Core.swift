import Foundation

class Core {
    static var Username : String = "leonardo"
    static var Services : [Service] = []
    static var Actions : [Action] = []
    static var Catalog : [String:[CatalogItem]] = [:]
    
    class func populateAll(withCallback callback:(()->())?) {
        Unifai.getServices({services in
            Core.Services = services
            Unifai.getActions({ actions in
                Core.Actions = actions
                Unifai.getCatalog({ catalog in
                    Core.Catalog = catalog
                    if callback != nil {
                        callback!()
                    }
                })
            })
        })
       
    }
}