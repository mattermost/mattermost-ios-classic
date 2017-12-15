// Copyright (c) 2015 Mattermost, Inc. All Rights Reserved.
// See License.txt for license information.

import UIKit
import JavaScriptCore


class MyURLProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
        DispatchQueue.main.async {
            //print("canInitWithRequest: " + (request.URL?.absoluteString)!)
            
            if request.url == nil ||  request.url?.host == nil {
                return
            }
            
            let isServer = Utils.getServerUrl().contains((request.url?.host)!)
            let app = UIApplication.shared.delegate as! AppDelegate
            
            let nav = app.window!.rootViewController as! UINavigationController
            if let currentView = nav.visibleViewController as? HomeViewController {
                
                let isGetFile = request.url?.path.contains("/files/") ?? false
                if (isServer && isGetFile) {
                    return
                }
                
                let isTownSquare  = request.url?.path.contains("/channels/town-square") ?? false
                if (isServer && isTownSquare) {
                    print("canInitWithRequest.attemptToAttachDevice: " + (request.url?.absoluteString)!)
                    currentView.performSelector(onMainThread: #selector(HomeViewController.attemptToAttachDevice), with: nil, waitUntilDone: false)
                    return
                }
                
                let isLogin  = request.url?.path.contains("/login") ?? false
                if (isServer && isLogin) {
                    print("login detected")
                    Utils.setProp(ATTACHED_DEVICE, value: "")
                    return
                }
                
                let isLogout  = request.url?.path.contains("/users/logout") ?? false
                if (isServer && isLogout) {
                    print("logout detected")
                    currentView.performSelector(onMainThread: #selector(HomeViewController.logoutPressed), with: nil, waitUntilDone: false)
                    return
                }
                
                currentView.performSelector(onMainThread: #selector(HomeViewController.checkForRoot), with: nil, waitUntilDone: false)
            }
        }
        
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
    var lpg: UILongPressGestureRecognizer!
    var keyboardVisible = false
    
    var api: MattermostApi = MattermostApi()
    
    @objc func attemptToAttachDevice() {
        let mmsid = Utils.getCookie(MATTERM_TOKEN)
        if (mmsid != "") {
            Utils.setProp(MATTERM_TOKEN, value: mmsid)
            if (Utils.getProp(ATTACHED_DEVICE) != "true") {
                print("Attaching device id to session")
                api.attachDeviceId()
            }
        }
    }
    
    @objc func checkForRoot() {
        let path = webView.stringByEvaluatingJavaScript(from: "window.location.pathname")!
        let server = webView.stringByEvaluatingJavaScript(from: "window.location.hostname")!
        let isServer = Utils.getServerUrl().contains(server)
        
        //print("jspath: " + path)
        
        if isServer && path.contains("/channels/") {
            Utils.setProp(LAST_CHANNEL, value: path)
        } else {
            Utils.setProp(LAST_CHANNEL, value: "")
        }

        if isServer && path == "/login" {
            self.navigationController?.isNavigationBarHidden = false
            return
        }
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @objc func logoutPressed() {
        if let navController = self.navigationController {
            Utils.setProp(ATTACHED_DEVICE, value: "")
            self.navigationController?.isNavigationBarHidden = false
            navController.popViewController(animated: true)
        }
    }
    
    func longPress() {
        if (keyboardVisible) {
            return
        }
        
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Select Different Server", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            print("Attempting logout")
            if let navController = self.navigationController {
                self.navigationController?.isNavigationBarHidden = false
                navController.popViewController(animated: true)
            }
        })
        
        let saveAction = UIAlertAction(title: "Refresh", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Attempting refresh")
            self.doRootView(true);
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func gestureRecognizer(_: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
            return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeView = self
        
        NotificationCenter.default.addObserver(self, selector:#selector(HomeViewController.keyboardWillAppear(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(HomeViewController.keyboardWillDisappear(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        URLProtocol.registerClass(MyURLProtocol.self)
        webView.delegate = self
        webView.scrollView.bounces = false
        self.navigationController?.isNavigationBarHidden = true
        api.delegate = self
        
        let context = webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as! JSContext
        let logFunction : @convention(block) (String) -> Void =
        {
            (msg: String) in
            NSLog("Console: %@", msg)
        }
        context.objectForKeyedSubscript("console").setObject(unsafeBitCast(logFunction, to: AnyObject.self), forKeyedSubscript: "log" as NSCopying & NSObjectProtocol)
        
        let type: UIUserNotificationType = [UIUserNotificationType.badge, UIUserNotificationType.alert, UIUserNotificationType.sound];
        let setting = UIUserNotificationSettings(types: type, categories: nil);
        UIApplication.shared.registerUserNotificationSettings(setting);
        UIApplication.shared.registerForRemoteNotifications();
        
        //lpg = UILongPressGestureRecognizer(target:self, action:"longPress")
        //lpg.minimumPressDuration = 0.3
        //webView.addGestureRecognizer(lpg)
        
        doRootView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillAppear(_ notification: Notification){
        keyboardVisible = true
    }
    
    @objc func keyboardWillDisappear(_ notification: Notification){
        keyboardVisible = false
    }
    
    func doBlank() {
        print("doBlank")
        webView.loadRequest(URLRequest(url: URL(string: "about:blank")!))
    }
    
    func doRootView(_ force:Bool=false) {
        print("doRootView")
        activityIndicator.startAnimating()
        currentUrl = Utils.getServerUrl() + Utils.getProp(LAST_CHANNEL)
        
//        if (!force) {
//            if let webViewUrl = webView.request?.URL!.absoluteString {
//                if (webViewUrl.containsString(currentUrl)) {
//                    print("skippingDoRootView")
//                    activityIndicator.stopAnimating()
//                    return
//                }
//            }
//        }
        
        let url = URL(string: currentUrl)
        let request = URLRequest(url: url!)
        webView.loadRequest(request)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        activityIndicator.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityIndicator.stopAnimating()
        //webView.stringByEvaluatingJavaScriptFromString("document.body.style.webkitTouchCallout='none';")
    }
    
    @IBAction func back(_ sender: AnyObject) {
        self.navigationController?.isNavigationBarHidden = true
        
        if Utils.getProp(LAST_CHANNEL).count > 0 {
            doRootView(true);
        } else {
            if let navController = self.navigationController {
                self.navigationController?.isNavigationBarHidden = false
                navController.popViewController(animated: true)
            }
        }
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print("Home view fail with error \(error)");
        activityIndicator.stopAnimating()
        if (error._code == 204 && error._domain == "WebKitErrorDomain") {
            // "Plug-in handled load" (i.e. audio/video file)
            return
        }
        
        if errorCount < 3 {
            sleep(3)
            self.doRootView(true);
            errorCount = errorCount + 1
            return
        }
        
        errorCount = 0
        
        let refreshAlert = UIAlertController(title: "Loading Error", message: "You may be offline or the Mattermost server you're trying to connect to is experiencing problems.", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Refresh", style: .default, handler: { (action: UIAlertAction!) in
            print("Attempting refresh")
            self.doRootView(true);
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Logout", style: .default, handler: { (action: UIAlertAction!) in
            print("Attempting logout")
            if let navController = self.navigationController {
                self.navigationController?.isNavigationBarHidden = false
                navController.popViewController(animated: true)
            }
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        //print("shouldStartLoadWithRequest: " + (request.URL?.absoluteString)!)
        
        if ("about:blank" == request.url?.absoluteString) {
            return false
        }
        
        // Open mailto: another browser
        let isMailTo = request.url?.absoluteString.hasPrefix("mailto:") ?? false
        if (isMailTo) {
            UIApplication.shared.openURL(request.url!)
            return false
        }
        
        let mmsid = Utils.getCookie(MATTERM_TOKEN)
        if (mmsid == "") {
            return true
        }
        
        // If something is being loaded in an iframe then do not open in a new tab
        let isIFrame = request.url?.absoluteString != request.mainDocumentURL?.absoluteString
        if (isIFrame) {
            return true
        }
        
        // Open all external links in another browser
        if (!currentUrl.contains((request.url?.host)!)) {
            UIApplication.shared.openURL(request.url!)
            return false
        }
        
        // Open help link in another browser
        let isHelp  = request.url?.path.contains("/static/help") ?? false
        if (currentUrl.contains((request.url?.host)!) && isHelp) {
            UIApplication.shared.openURL(request.url!)
            return false
        }
        
        // Open files in another browser
        let isGetFile = request.url?.path.contains("/files/") ?? false
        if (currentUrl.contains((request.url?.host)!) && isGetFile) {
            self.navigationController?.isNavigationBarHidden = false
            return true
        }
        
        return true
    }
    
    func didRecieveResponse(_ results: JSON) {
        print("Successfully attached device id to session")
        Utils.setProp(ATTACHED_DEVICE, value: "true")
    }
    
    func didRecieveError(_ message: String) {
        print("Failed attaching device id to session")
        print(message)
    }
}
