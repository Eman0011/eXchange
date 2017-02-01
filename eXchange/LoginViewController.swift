//
//  LoginViewController.swift
//  eXchange
//
//  Created by Emanuel Castaneda on 4/6/16.
//  Copyright © 2016 Emanuel Castaneda. All rights reserved.
//

import UIKit
import WebKit

class LoginViewController: UIViewController, WKNavigationDelegate {
    
    var netid: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "http://www.cs.princeton.edu/~cmoretti/cos333/CAS/CAStestpy.cgi")
        let marginTop:CGFloat = self.view.bounds.height * 0.05;
        let marginLeft:CGFloat = self.view.bounds.width * 0.08
        let width:CGFloat = self.view.bounds.width - marginLeft
        let height = self.view.bounds.height - marginTop
        let webView = WKWebView(frame: CGRect(x: marginLeft, y: marginTop, width: width, height: height))

        webView.navigationDelegate = self
        self.view.addSubview(webView)
        webView.load(URLRequest(url: url!))
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.body.innerHTML") { (result, error) in
            let page = result as! String
            if page.contains("Hello") {
                let lines = page.characters.split(separator: "\n").map { String($0) }
                let line = lines[0]
                let start = line.index((line.characters.index(of: ","))!, offsetBy: 2)
                self.netid = line.substring(from: start)
                self.performSegue(withIdentifier: "tabBar", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! eXchangeTabBarController
        // uncomment this to un-hardcode userNetID
        destination.userNetID = self.netid
    }

}
