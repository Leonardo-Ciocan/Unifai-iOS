//
//  AuthViewController.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 02/06/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit
import PKHUD

protocol AuthViewDelegate {
    func didFinishAuthentication()
}

class AuthViewController: UIViewController  , UIWebViewDelegate{

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var service : Service?
    var payload : RequestAuthPayload?
    var delegate : AuthViewDelegate?
    
    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = true
        super.viewDidLoad()
        header.backgroundColor = service?.color
        titleLabel.text = service?.name.uppercaseString
        var authorizationURL : NSURL?
        if payload!.fullAuthorizationURL.isEmpty {
            let urlComponents = NSURLComponents(string: payload!.url)
            urlComponents?.queryItems = [
                NSURLQueryItem(name: "redirect_uri", value: "http://127.0.0.1:1989/callback"),
                NSURLQueryItem(name: "client_id", value: payload?.clientID),
                NSURLQueryItem(name: "response_type", value: "code"),
                NSURLQueryItem(name: "state", value: "unifai"),
                NSURLQueryItem(name: "scope", value: payload?.scope),
                NSURLQueryItem(name: "duration", value: "permanent"),
            ]
            authorizationURL = urlComponents?.URL
        }
        else {
            authorizationURL = NSURL(string: payload!.fullAuthorizationURL)
        }
        let request = NSURLRequest(URL:authorizationURL!)
        print(authorizationURL?.absoluteString)
        webView.delegate = self
        webView.scrollView.contentInset = UIEdgeInsetsMake(70, 0,0, 0)
        webView.clipsToBounds = false
        webView.loadRequest(request)
    }

    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let url : String = request.URL?.absoluteString{
            if(url.containsString(payload!.parameterNameToCapture +  "=")){
                let urlComponents = NSURLComponents(string:url)
                let code = urlComponents?.queryItems?.filter({ $0.name == payload!.parameterNameToCapture}).first?.value
                print(code)
                Unifai.updateAuthCode((service?.id)!, code: code!, completion: {
                    _ in
                    self.dismissViewControllerAnimated(true, completion: nil)
                    self.delegate?.didFinishAuthentication()
                    HUD.flash(.Success, delay: 1)
                })
                return false
            }
        }
        return true
    }
    
    @IBAction func closeTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        print(error?.localizedDescription)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

}
