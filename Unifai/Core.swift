import Foundation

class Core {
    static var Username : String = ""
    static var Services : [Service] = []
    static var Actions : [Action] = []
    static var Catalog : [String:[CatalogItem]] = [:]
    
    class func populateAll(withCallback callback:(()->())?, error : @escaping (ResponseStatus) -> ()) {
        Unifai.getUserInfo({ username,email in
            Core.Username = username
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
            }, error: {
                status in
                error(status)
        })
        
       
    }
}
