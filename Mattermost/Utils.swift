// Copyright (c) 2015 Mattermost, Inc. All Rights Reserved.
// See License.txt for license information.

import UIKit

let ATTACHED_DEVICE = "AttachedDevice"
let MATTERM_TOKEN = "MMAUTHTOKEN"
let DEVICE_TOKEN = "DeviceToken"
let CURRENT_USER = "CurrentUser"
let CURRENT_USER_EMAIL = "CurrentUserEmail"
let CURRENT_TEAM_NAME = "CurrentTeamName"
let CURRENT_URL = "CurrentUrl"
let CURRENT_BACKGROUND_TIME = "CurrentBackTime"
let LAST_CHANNEL = "LastChannel"

let BASE_URL_MATTERMOST = ""

class Utils {
    class func HandleUIError(_ message: String, label: UILabel) {
        label.center = CGPoint(x: label.center.x - 10, y: label.center.y)
        label.text = message
        label.alpha = 1
        label.textColor = UIColor.red
        
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.1, initialSpringVelocity: 0.0, options: [], animations: {
            label.center = CGPoint(x: label.center.x + 10, y: label.center.y)
            }, completion: nil)
    }
    
    static var defaults: UserDefaults = UserDefaults.standard
    
    class func getProp(_ key: String) -> String! {
        
        if let v = defaults.string(forKey: key) {
            return v
        }
        
        return ""
    }
    
    class func setWentToBackground() {
        defaults.setValue(Date().timeIntervalSince1970, forKey: CURRENT_BACKGROUND_TIME)
    }
    
    class func getShouldForceUpdate() -> Bool {
        let now = Date().timeIntervalSince1970
        let time = defaults.double(forKey: CURRENT_BACKGROUND_TIME)
        
        if (time == 0) {
            return true
        }
                
        if (now - time < 300) {
            return false
        }

        return true
    }
    
    class func setServerUrl(_ serverUrl: String) {
        var serverUrl = serverUrl
        if (serverUrl.characters.count != 0 && serverUrl[serverUrl.characters.index(serverUrl.endIndex, offsetBy: -1)] == "/") {
            serverUrl = serverUrl.substring(to: serverUrl.characters.index(serverUrl.endIndex, offsetBy: -1))
        }
        
        setProp(CURRENT_URL, value: serverUrl)
    }
    
    class func getServerUrl() -> String! {
        return getProp(CURRENT_URL)
    }
    
    class func setTeamUrl(_ teamUrl: String) {
        var teamUrl = teamUrl
        
        if (teamUrl[teamUrl.characters.index(teamUrl.endIndex, offsetBy: -1)] == "/") {
            teamUrl = teamUrl.substring(to: teamUrl.characters.index(teamUrl.endIndex, offsetBy: -1))
        }
        
        let index = teamUrl.range(of: "/", options: .backwards)?.lowerBound
        if (index != nil) {
            setProp(CURRENT_URL, value: teamUrl.substring(to: index!))
            setProp(CURRENT_TEAM_NAME, value: teamUrl.substring(to: index!))
        }
    }
    
    class func setProp(_ key: String, value: String) {
        defaults.setValue(value, forKey: key)
    }
    
    class func getCookie(_ key: String) -> String {
        let _ : HTTPCookie = HTTPCookie()
        let cookieJar : HTTPCookieStorage = HTTPCookieStorage.shared

        for cookie in cookieJar.cookies! as [HTTPCookie]{
            if (cookie.name == key) {
                return cookie.value
            }
        }
        
        return ""
    }
}
