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
    func didSelectAutocompletion(message:String)
    func shouldDismiss()
}

class CreatorAssistant: UIView , AutoCompletionServicesDelegate , AutoCompletionSuggestionsDelegate , PromptViewDelegate {
    @IBOutlet weak var suggestionsView: AutoCompletionSuggestions!
    @IBOutlet weak var serviceAutoCompleteView: AutoCompletionServices!
    @IBOutlet weak var promptView: PromptView!
    
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
        suggestionsView.delegate = self
        promptView.delegate = self
        self.addSubview(view);
    }
    
    var isInPromptMode = false
    
    func enablePromptModeWithSuggestions(service : Service, suggestions:[SuggestionItem]) {
        self.isInPromptMode = true
        promptView.service = service
        promptView.suggestions = suggestions
    }
    
    func disablePromptMode() {
        self.isInPromptMode = false
        promptView.service = nil
        promptView.suggestions = []
    }
    
    func autocompleteFor(query:String) {
        let autocompletionState = Autocomplete.computeState(fromText: query)
        if isInPromptMode {
            suggestionsView.hidden = true
            serviceAutoCompleteView.hidden = true
            promptView.hidden = false
            promptView.filterPromptsWithKeywords(autocompletionState.keywords)
            return
        }
        serviceAutoCompleteView.filterServices(autocompletionState.service)
        suggestionsView.filterSuggestionsWithKeywords(autocompletionState.keywords)
        
        if query.containsString(" ") {
            serviceAutoCompleteView.hidden = true
            suggestionsView.hidden = false
            if query.hasSuffix(" ") && query.characters.filter({ $0 == " " }).count == 1 {
                if let service = TextUtils.extractService(query) {
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
        suggestionsView.serviceColor = service.color
        suggestionsView.suggestions = Core.Catalog[service.username] ?? []
        suggestionsView.actions = Core.Actions.filter({ TextUtils.extractService($0.message) == service })
        suggestionsView.filterSuggestionsWithKeywords([])
        suggestionsView.tableView.reloadData()
    }

    func shouldHideServiceAutocompletion() {
        serviceAutoCompleteView.hidden = true
        suggestionsView.hidden = false
    }
    
    func didSelectAutocompletion(message: String) {
        self.delegate?.didSelectAutocompletion(message)
    }
    
    func resetAutocompletion(){
        serviceAutoCompleteView.hidden = false
        suggestionsView.hidden = true
        serviceAutoCompleteView.filterServices("")
        suggestionsView.filterSuggestionsWithKeywords([])
    }
    
    func didSelectPromptSuggestionWithName(name: String) {
        self.delegate?.didSelectAutocompletion(name)
    }
    
    func shouldDismiss() {
        self.delegate?.shouldDismiss()
    }
}
