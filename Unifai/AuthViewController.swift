//
//  AuthViewController.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 02/06/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

class AuthViewController: UIViewController  , UIWebViewDelegate{

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var service : Service?
    var payload : RequestAuthPayload?
    
    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = true
        super.viewDidLoad()
        header.backgroundColor = service?.color
        titleLabel.text = service?.name
        var urlComponents = NSURLComponents(string: payload!.url)
        urlComponents?.queryItems = [
            NSURLQueryItem(name: "redirect_uri", value: "http://127.0.0.1:1989/callback"),
            NSURLQueryItem(name: "client_id", value: payload?.clientID),
            NSURLQueryItem(name: "response_type", value: "code"),
            NSURLQueryItem(name: "state", value: "unifai"),
            NSURLQueryItem(name: "scope", value: "identity"),
            NSURLQueryItem(name: "duration", value: "permanent"),
        ]
        var url = urlComponents?.URL
        var request = NSURLRequest(URL:url!)
        print(url?.absoluteString)
        webView.delegate = self
        webView.scrollView.contentInset = UIEdgeInsetsMake(70, 0,0, 0)
        webView.clipsToBounds = false
        webView.loadRequest(request)
    }

    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let url : String = request.URL?.absoluteString{
            print("loaded")
            if(url.containsString("code=")){
                var urlComponents = NSURLComponents(string:url)
                let code = urlComponents?.queryItems?.filter({ $0.name == "code"}).first?.value
                print(code)
                Unifai.updateAuthCode((service?.id)!, code: code!, completion: {
                    _ in
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
                return false
            }
        }
        return true
    }
    
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        print(error?.localizedDescription)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

}
