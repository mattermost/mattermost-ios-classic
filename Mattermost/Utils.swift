// Copyright (c) 2015 Mattermost, Inc. All Rights Reserved.
// See License.txt for license information.

import UIKit

let ATTACHED_DEVICE = "AttachedDevice"
let MATTERM_TOKEN = "MMTOKEN"
let DEVICE_TOKEN = "DeviceToken"
let CURRENT_USER = "CurrentUser"
let CURRENT_USER_EMAIL = "CurrentUserEmail"
let CURRENT_TEAM_NAME = "CurrentTeamName"
let CURRENT_URL = "CurrentUrl"
let CURRENT_BACKGROUND_TIME = "CurrentBackTime"

let BASE_URL_MATTERMOST = ""

class Utils {
    class func HandleUIError(message: String, label: UILabel) {
        label.center = CGPoint(x: label.center.x - 10, y: label.center.y)
        label.text = message
        label.alpha = 1
        label.textColor = UIColor.redColor()
        
        UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.1, initialSpringVelocity: 0.0, options: [], animations: {
            label.center = CGPoint(x: label.center.x + 10, y: label.center.y)
            }, completion: nil)
    }
    
    static var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    class func getProp(key: String) -> String! {
        
        if let v = defaults.stringForKey(key) {
            return v
        }
        
        return ""
    }
    
    class func setWentToBackground() {
        defaults.setValue(NSDate().timeIntervalSince1970, forKey: CURRENT_BACKGROUND_TIME)
    }
    
    class func getShouldForceUpdate() -> Bool {
        let now = NSDate().timeIntervalSince1970
        let time = defaults.doubleForKey(CURRENT_BACKGROUND_TIME)

        if (time == 0) {
            return true
        }

        if (now - time < 300) {
            return false
        }

        return true
    }
    
    class func setTeamUrl(var teamUrl: String) {
        
        if (!teamUrl.isEmpty) {
            if (teamUrl[teamUrl.endIndex.advancedBy(-1)] == "/") {
                teamUrl = teamUrl.substringToIndex(teamUrl.endIndex.advancedBy(-1))
            }
            
            let index = teamUrl.rangeOfString("/", options: .BackwardsSearch)?.startIndex
            if (index != nil) {
                setProp(CURRENT_URL, value: teamUrl.substringToIndex(index!))
                setProp(CURRENT_TEAM_NAME, value: teamUrl.substringFromIndex(index!.advancedBy(1)))
            }
        }
    }
    
    class func setProp(key: String, value: String) {
        defaults.setValue(value, forKey: key)
    }
    
    class func getCookie(key: String) -> String {
        let _ : NSHTTPCookie = NSHTTPCookie()
        let cookieJar : NSHTTPCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()

        for cookie in cookieJar.cookies! as [NSHTTPCookie]{
            if (cookie.name == key) {
                return cookie.value
            }
        }
        
        return ""
    }
}
