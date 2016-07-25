//
//  CreatorAssistant.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 13/07/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

protocol CreatorAssistantDelegate {
    func selectedService(service:Service?, selectedByTapping : Bool)
}

class CreatorAssistant: UIView , AutoCompletionServicesDelegate {
    @IBOutlet weak var suggestionsView: AutoCompletionSuggestions!
    @IBOutlet weak var serviceAutoCompleteView: AutoCompletionServices!
    
    var delegate : CreatorAssistantDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib ()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib ()
    }
    
    func loadViewFromNib() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "CreatorAssistant", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.serviceAutoCompleteView.delegate = self
        self.addSubview(view);
    }
    
    func autocompleteFor(query:String) {
        let autocompletionState = Autocomplete.computeState(fromText: query)
        serviceAutoCompleteView.filterServices(autocompletionState.service)
        suggestionsView.filterSuggestionsWithKeywords(autocompletionState.keywords)
        
        if query.containsString(" ") {
            serviceAutoCompleteView.hidden = true
            suggestionsView.hidden = false
            if query.hasSuffix(" ") && query.characters.filter({ $0 == " " }).count == 1 {
                if let service = extractService(query) {
                    self.selectedService(service , selectedByTapping: false)
                }
            }
        }
        else {
            serviceAutoCompleteView.hidden = false
            suggestionsView.hidden = true
            self.delegate?.selectedService(nil , selectedByTapping: false)
        }
        
    }
    
    func selectedService(service: Service , selectedByTapping : Bool) {
        delegate?.selectedService(service , selectedByTapping: selectedByTapping)
        suggestionsView.backgroundColor = service.color
        suggestionsView.suggestions = Core.Catalog[service.username]!
        suggestionsView.filterSuggestionsWithKeywords([])
        suggestionsView.tableView.reloadData()
    }

    func shouldHideServiceAutocompletion() {
        serviceAutoCompleteView.hidden = true
        suggestionsView.hidden = false
    }
}
