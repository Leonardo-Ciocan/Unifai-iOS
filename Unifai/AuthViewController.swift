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
        titleLabel.text = service?.name.uppercased()
        var authorizationURL : URL?
        if payload!.fullAuthorizationURL.isEmpty {
            var urlComponents = URLComponents(string: payload!.url)
            urlComponents?.queryItems = [
                URLQueryItem(name: "redirect_uri", value: "http://127.0.0.1:1989/callback"),
                URLQueryItem(name: "client_id", value: payload?.clientID),
                URLQueryItem(name: "response_type", value: "code"),
                URLQueryItem(name: "state", value: "unifai"),
                URLQueryItem(name: "scope", value: payload?.scope),
                URLQueryItem(name: "duration", value: "permanent"),
            ]
            authorizationURL = urlComponents?.url
        }
        else {
            authorizationURL = URL(string: payload!.fullAuthorizationURL)
        }
        let request = URLRequest(url:authorizationURL!)
        print(authorizationURL?.absoluteString)
        webView.delegate = self
        webView.scrollView.contentInset = UIEdgeInsetsMake(70, 0,0, 0)
        webView.clipsToBounds = false
        webView.loadRequest(request)
    }

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let url : String = request.url?.absoluteString{
            if(url.contains(payload!.parameterNameToCapture +  "=")){
                let urlComponents = URLComponents(string:url)
                let code = urlComponents?.queryItems?.filter({ $0.name == payload!.parameterNameToCapture}).first?.value
                print(code)
                Unifai.updateAuthCode((service?.id)!, code: code!, completion: {
                    _ in
                    self.dismiss(animated: true, completion: nil)
                    self.delegate?.didFinishAuthentication()
                    HUD.flash(.success, delay: 1)
                })
                return false
            }
        }
        return true
    }
    
    @IBAction func closeTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print(error.localizedDescription)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

}
