// Copyright (c) 2015 Mattermost, Inc. All Rights Reserved.
// See License.txt for license information.

import Foundation
import UIKit

protocol MattermostApiProtocol {
    func didRecieveResponse(result: JSON)
    func didRecieveError(message: String)
}

public class MattermostApi: NSObject {
    
    var baseUrl = ""
    var data: NSMutableData = NSMutableData()
    var statusCode = 200
    var delegate: MattermostApiProtocol?
    
    override init() {
        super.init()
        self.initBaseUrl()
    }
    
    func initBaseUrl() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let url = defaults.stringForKey(CURRENT_URL)
        
        if (url != nil && (url!).characters.count > 0) {
            baseUrl = url!
        }
    }
    
    func doPost(url: String, data: JSON) ->  NSURLConnection {
        print(baseUrl + url)
        let url: NSURL = NSURL(string: baseUrl + url)!
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = try! data.rawData()
        let connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: false)!
        
        return connection
    }
    
    func signup(email: String, name: String) {
        let connection = doPost("/api/v1/teams/signup", data: JSON(["email": email, "name" : name]))
        connection.start()
    }
    
    func findTeams(email: String) {
        let connection = doPost("/api/v1/teams/email_teams", data: JSON(["email": email]))
        connection.start()
    }
    
    func attachDeviceId() {
        let connection = doPost("/api/v1/users/attach_device", data: JSON(["device_id": "apple:" + Utils.getProp(DEVICE_TOKEN)]))
        connection.start()
    }
    
    func findTeamByName(name: String) {
        let connection = doPost("/api/v1/teams/find_team_by_name", data: JSON(["name": name]))
        connection.start()
    }
    
    func login(email: String, password: String) {
        let defaults = NSUserDefaults.standardUserDefaults()
        let teamName = defaults.stringForKey(CURRENT_TEAM_NAME)
        var json :JSON = ["name":teamName!]
        json["email"] = JSON(email)
        json["password"] = JSON(password)
        json["device_id"] = JSON("apple:" + Utils.getProp(DEVICE_TOKEN))
        let connection = doPost("/api/v1/users/login", data: json)
        connection.start()
    }
    
    func forgotPassword(email: String) {
        let defaults = NSUserDefaults.standardUserDefaults()
        let teamName = defaults.stringForKey(CURRENT_TEAM_NAME)
        var json :JSON = ["name":teamName!]
        json["email"] = JSON(email)
        let connection = doPost("/api/v1/users/send_password_reset", data: json)
        connection.start()
    }
    
    func connection(connection: NSURLConnection!, didFailWithError error: NSError!) {
        statusCode = error.code
        print("Error: statusCode=\(statusCode) data=\(error.localizedDescription)")
        delegate?.didRecieveError("\(error.localizedDescription) [\(statusCode)]")
    }
    
    func connection(didReceiveResponse: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        statusCode = (response as? NSHTTPURLResponse)?.statusCode ?? -1
        self.data = NSMutableData()
        
        let mmsid = Utils.getCookie(MATTERM_TOKEN)
        Utils.setProp(MATTERM_TOKEN, value: mmsid)
        print(mmsid)
        if (mmsid == "") {
            Utils.setProp(CURRENT_USER, value: "")
            Utils.setProp(MATTERM_TOKEN, value: "")
        }
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        self.data.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        let json = JSON(data: data)
        
        if (statusCode == 200) {
            delegate?.didRecieveResponse(json)
        } else {
            let datastring = NSString(data: data, encoding: NSUTF8StringEncoding)
            print("Error: statusCode=\(statusCode) data=\(datastring)")
            
            if let message = json["message"].string {
                delegate?.didRecieveError(message)
            } else {
                delegate?.didRecieveError(NSLocalizedString("UNKOWN_ERR", comment: "An unknown error has occured. (-1)"))
            }
        }
    }
}

