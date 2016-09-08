// Copyright (c) 2015 Mattermost, Inc. All Rights Reserved.
// See License.txt for license information.

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UINavigationControllerDelegate  {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let signInController = self.window!.rootViewController as! UINavigationController
        signInController.delegate = self
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let token = defaults.stringForKey(MATTERM_TOKEN)
        
        if (token != nil && (token!).characters.count > 0) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            //let loginInView = storyboard.instantiateViewControllerWithIdentifier("EmailPasswordView")
            //signInController.pushViewController(loginInView, animated: false)
            
            let HomeView = storyboard.instantiateViewControllerWithIdentifier("HomeView") 
            signInController.pushViewController(HomeView, animated: false)
        }
        
        return true
    }

    func applicationDidEnterBackground(application: UIApplication) {
        print("DidEnterBackground")
        Utils.setWentToBackground()
//        let nav = self.window!.rootViewController as! UINavigationController
//        if let currentView = nav.visibleViewController as? HomeViewController {
//            currentView.doBlank()
//        }
    }

    func applicationWillEnterForeground(application: UIApplication) {
        print("WillEnterForeground")
        
        let force = Utils.getShouldForceUpdate()
        print(force)

        if (force) {
            let nav = self.window!.rootViewController as! UINavigationController
            if let currentView = nav.visibleViewController as? HomeViewController {
                currentView.doRootView(force)
            }
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        print("WillResignActive")
    }

    func applicationDidBecomeActive(application: UIApplication) {
        print("DidBecomeActive")
        application.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(application: UIApplication) {
        print("WillTerminate")
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for var i = 0; i < deviceToken.length; i++ {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }

        print("deviceToken=\(tokenString)")
        Utils.setProp(DEVICE_TOKEN, value: tokenString)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print(error)
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler handler: (UIBackgroundFetchResult) -> Void) {
        print(userInfo)
        handler(UIBackgroundFetchResult.NewData)
    }
}

