//
//  RecipeInstructionsWebViewController.swift
//  BetterU
//
//  Created by Hung Vu on 4/7/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit
import WebKit

class RecipeInstructionsWebViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var webView: UIWebView!
    var recipeUrl = ""
    var recipeTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = recipeTitle
        
        // Convert to NSURL
        let url = NSURL(string: recipeUrl)
        
        // Convert to NSURLRequest
        let request = NSURLRequest(URL: url!)
        
        // Asks webview to load that request
        self.webView!.loadRequest(request)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     ----------------------------------
     MARK: - WebView Delegate Methods
     ----------------------------------
     */
    func webViewDidStartLoad(webView: UIWebView) {
        // Starting to load the web page. Show the animated activity indicator in the status bar
        // to indicate to the user that the UIWebVIew object is busy loading the web page.
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        // Finished loading the web page. Hide the activity indicator in the status bar.
        activityIndicator.hidden = true
        activityIndicator.stopAnimating()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        /*
         Ignore this error if the page is instantly redirected via javascript or in another way.
         NSURLErrorCancelled is returned when an asynchronous load is cancelled, which happens
         when the page is instantly redirected via javascript or in another way.
         */
        if error!.code == NSURLErrorCancelled {
            return
        }
        
        // An error occurred during the web page load. Hide the activity indicator in the status bar.
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        // Create the error message in HTML as a character string and store it into the local constant errorString
        let errorString = "<html><font size=+2 color='red'><p>An error occurred: <br />Possible causes for this error:<br />- No network connection<br />- Wrong URL entered<br />- Server computer is down</p></font></html>" + error!.localizedDescription
        
        // Display the error message within the UIWebView object
        self.webView!.loadHTMLString(errorString, baseURL: nil)
    }


}
