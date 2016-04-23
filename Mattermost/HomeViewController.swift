// Copyright (c) 2015 Mattermost, Inc. All Rights Reserved.
// See License.txt for license information.

import UIKit

class MyURLProtocol: NSURLProtocol {
    override class func canInitWithRequest(request: NSURLRequest) -> Bool {
        
//        if let hv = homeView {
//            let isLogout  = request.URL?.path?.containsString("/users/logout") ?? false
//            if (hv.currentUrl.containsString((request.URL?.host)!) && isLogout) {
//                hv.longPress()
//                return true
//            }
//        }
        
//        if (request.URL!.path == "/logout") {
//            logoutCalled = true
//            
//        }
        
//        NSLog(request.URL!.path!)
        
        return false
    } 
}

var homeView: HomeViewController?

class HomeViewController: UIViewController, UIWebViewDelegate, MattermostApiProtocol, UIGestureRecognizerDelegate  {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    var currentUrl: String = ""
    var errorCount = 0
    
    var api: MattermostApi = MattermostApi()
    
    func longPress() {
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .ActionSheet)
        
        let deleteAction = UIAlertAction(title: "Select Different Server", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            print("Attempting logout")
            if let navController = self.navigationController {
                self.navigationController?.navigationBarHidden = false
                navController.popViewControllerAnimated(true)
            }
        })
        
        let saveAction = UIAlertAction(title: "Refresh", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Attempting refresh")
            self.doRootView(true);
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    func gestureRecognizer(_: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
            return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeView = self
        NSURLProtocol.registerClass(MyURLProtocol)
        webView.delegate = self
        webView.scrollView.bounces = false
        self.navigationController?.navigationBarHidden = true
        api.delegate = self
        
        let type: UIUserNotificationType = [UIUserNotificationType.Badge, UIUserNotificationType.Alert, UIUserNotificationType.Sound];
        let setting = UIUserNotificationSettings(forTypes: type, categories: nil);
        UIApplication.sharedApplication().registerUserNotificationSettings(setting);
        UIApplication.sharedApplication().registerForRemoteNotifications();
        
        let lpg = UILongPressGestureRecognizer(target:self, action:"longPress")
        lpg.minimumPressDuration = 0.3
        
        webView.addGestureRecognizer(lpg)
        
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
        currentUrl = defaults.stringForKey(CURRENT_URL)!
        
        if (!force) {
            if let webViewUrl = webView.request?.URL!.absoluteString {
                if (webViewUrl.containsString(currentUrl)) {
                    print("skippingDoRootView")
                    activityIndicator.stopAnimating()
                    return
                }
            }
        }
        
        let url = NSURL(string: currentUrl)
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
            Utils.setProp(ATTACHED_DEVICE, value: "")
        } else {
            if (Utils.getProp(ATTACHED_DEVICE) != "true") {
                print("Attaching device id to session")
                api.attachDeviceId()
            }
        }
        
        webView.stringByEvaluatingJavaScriptFromString("document.body.style.webkitTouchCallout='none';")
    }
    
    @IBAction func back(sender: AnyObject) {
        self.navigationController?.navigationBarHidden = true
        doRootView(true);
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        activityIndicator.stopAnimating()
        print("Home view fail with error \(error)");
        
        if errorCount < 3 {
            self.doRootView(true);
            errorCount = errorCount + 1
            return
        }
        
        errorCount = 0
        
        let refreshAlert = UIAlertController(title: "Loading Error", message: "You may be offline or the Mattermost server you're trying to connect to is experiencing problems.", preferredStyle: UIAlertControllerStyle.Alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Refresh", style: .Default, handler: { (action: UIAlertAction!) in
            print("Attempting refresh")
            self.doRootView(true);
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Logout", style: .Default, handler: { (action: UIAlertAction!) in
            print("Attempting logout")
            if let navController = self.navigationController {
                self.navigationController?.navigationBarHidden = false
                navController.popViewControllerAnimated(true)
            }
        }))
        
        presentViewController(refreshAlert, animated: true, completion: nil)
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        print(request.URL?.absoluteString)
        
        if ("about:blank" == request.URL?.absoluteString) {
            return false
        }
        
        // Open mailto: another browser
        let isMailTo = request.URL?.absoluteString.hasPrefix("mailto:") ?? false
        if (isMailTo) {
            UIApplication.sharedApplication().openURL(request.URL!)
            return false
        }
        
        let mmsid = Utils.getCookie(MATTERM_TOKEN)
        if (mmsid == "") {
            return true
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
        
        let isFile  = request.URL?.path?.containsString("/api/v3/files/get/") ?? false
        if (currentUrl.containsString((request.URL?.host)!) && isFile) {
            self.navigationController?.navigationBarHidden = false
            return true
        }
        
        return true
    }
    
    func didRecieveResponse(results: JSON) {
        print("Successfully attached device id to session")
        Utils.setProp(ATTACHED_DEVICE, value: "true")
    }
    
    func didRecieveError(message: String) {
        print("Failed attaching device id to session")
        print(message)
    }
}
