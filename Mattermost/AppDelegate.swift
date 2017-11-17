// Copyright (c) 2015 Mattermost, Inc. All Rights Reserved.
// See License.txt for license information.

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UINavigationControllerDelegate  {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let signInController = self.window!.rootViewController as! UINavigationController
        signInController.delegate = self
        
        let defaults = UserDefaults.standard
        let token = defaults.string(forKey: MATTERM_TOKEN)
        
        if (token != nil && (token!).count > 0) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            //let loginInView = storyboard.instantiateViewControllerWithIdentifier("EmailPasswordView")
            //signInController.pushViewController(loginInView, animated: false)
            
            let HomeView = storyboard.instantiateViewController(withIdentifier: "HomeView") 
            signInController.pushViewController(HomeView, animated: false)
        }
        
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("DidEnterBackground")
        Utils.setWentToBackground()
//        let nav = self.window!.rootViewController as! UINavigationController
//        if let currentView = nav.visibleViewController as? HomeViewController {
//            currentView.doBlank()
//        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
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
    
    func applicationWillResignActive(_ application: UIApplication) {
        print("WillResignActive")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("DidBecomeActive")
        application.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(_ application: UIApplication) {
        print("WillTerminate")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var tokenString = ""
        
        for i in 0 ..< deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }

        print("deviceToken=\(tokenString)")
        Utils.setProp(DEVICE_TOKEN, value: tokenString)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler handler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(userInfo)
        handler(UIBackgroundFetchResult.newData)
    }
}

