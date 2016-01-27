// Copyright (c) 2015 Mattermost, Inc. All Rights Reserved.
// See License.txt for license information.

import UIKit

class MyURLProtocol: NSURLProtocol {
    override class func canInitWithRequest(request: NSURLRequest) -> Bool {
//        if (request.URL!.path == "/logout") {
//            logoutCalled = true
//        }
        return false
    } 
}

class HomeViewController: UIViewController, UIWebViewDelegate  {
        
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var webView: UIWebView!
    var currentUrl: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSURLProtocol.registerClass(MyURLProtocol)
        webView.delegate = self
        webView.scrollView.bounces = false
        self.navigationController?.navigationBarHidden = true
        
        let type: UIUserNotificationType = [UIUserNotificationType.Badge, UIUserNotificationType.Alert, UIUserNotificationType.Sound];
        let setting = UIUserNotificationSettings(forTypes: type, categories: nil);
        UIApplication.sharedApplication().registerUserNotificationSettings(setting);
        UIApplication.sharedApplication().registerForRemoteNotifications();
        
        doRootView()
    }
    
    func doBlank() {
        print("doBlank")
        webView.loadRequest(NSURLRequest(URL: NSURL(string: "about:blank")!))
    }
    
    func doRootView(force:Bool=false) {
        print("doRootView")
        activityIndicator.startAnimating()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let teamName = defaults.stringForKey(CURRENT_TEAM_NAME)
        currentUrl = defaults.stringForKey(CURRENT_URL)!
        let fullUrl = currentUrl + "/" + teamName!
        
        if (!force) {
            if let webViewUrl = webView.request?.URL!.absoluteString {
                if (webViewUrl.containsString(currentUrl)) {
                    print("skippingDoRootView")
                    activityIndicator.stopAnimating()
                    return
                }
            }
        }
        
        let url = NSURL(string: fullUrl)
        let request = NSURLRequest(URL: url!)
        webView.loadRequest(request)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        activityIndicator.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        activityIndicator.stopAnimating()

        let mmsid = Utils.getCookie(MATTERM_TOKEN)
        Utils.setProp(MATTERM_TOKEN, value: mmsid)
        if (mmsid == "") {
            Utils.setProp(CURRENT_USER, value: "")
            Utils.setProp(MATTERM_TOKEN, value: "")
        }

//        if (mmsid == "") {
//            print("session expired or user logged out")
//            if let navController = self.navigationController {
//                self.navigationController?.navigationBarHidden = false
//                navController.popViewControllerAnimated(true)
//            }
//        }
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        print(request.URL?.absoluteString)
        
        if ("about:blank" == request.URL?.absoluteString) {
            return false
        }
        
        // If something is being loaded in an iframe then do not open in a new tab
        let isIFrame = request.URL?.absoluteString != request.mainDocumentURL?.absoluteString
        if (isIFrame) {
            return true
        }
        
        // Open all external links in another browser
        if (!currentUrl.containsString((request.URL?.host)!)) {
            UIApplication.sharedApplication().openURL(request.URL!)
            return false
        }
        
        // Open help link in another browser
        let isHelp  = request.URL?.path?.containsString("/static/help") ?? false
        
        if (currentUrl.containsString((request.URL?.host)!) && isHelp) {
            UIApplication.sharedApplication().openURL(request.URL!)
            return false
        }

        // Open file download link in another browser
        let isFile  = request.URL?.path?.containsString("/api/v1/files/get/") ?? false
        if (currentUrl.containsString((request.URL?.host)!) && isFile) {
            UIApplication.sharedApplication().openURL(request.URL!)
            return false
        }
        
        // If we access the root then send them back to the iOS root page
        if (currentUrl + "/" == request.URL?.absoluteString) {
            if let navController = self.navigationController {
                self.navigationController?.navigationBarHidden = false
                navController.popViewControllerAnimated(true)
            }
            
            return true
        }

        return true
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        print(error)
    }
}
