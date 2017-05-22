// Copyright (c) 2015 Mattermost, Inc. All Rights Reserved.
// See License.txt for license information.

import Foundation
import UIKit

protocol MattermostApiProtocol {
    func didRecieveResponse(_ result: JSON)
    func didRecieveError(_ message: String)
}

open class MattermostApi: NSObject {
    
    static let API_ROUTE = "/api/v3"
    
    var baseUrl = ""
    var data: NSMutableData = NSMutableData()
    var statusCode = 200
    var delegate: MattermostApiProtocol?
    
    override init() {
        super.init()
        self.initBaseUrl()
    }
    
    func initBaseUrl() {
        let defaults = UserDefaults.standard
        let url = defaults.string(forKey: CURRENT_URL)
        
        if (url != nil && (url!).characters.count > 0) {
            baseUrl = url!
        }
    }
    
    func doPost(_ url: String, data: JSON) ->  NSURLConnection {
        print(baseUrl + url)
        let url: URL = URL(string: baseUrl + url)!
        let request: NSMutableURLRequest = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        request.httpBody = try! data.rawData()
        let connection: NSURLConnection = NSURLConnection(request: request as URLRequest, delegate: self, startImmediately: false)!
        
        return connection
    }
    
    func doGet(_ url: String) ->  NSURLConnection {
        print(baseUrl + url)
        let url: URL = URL(string: baseUrl + url)!
        let request: NSMutableURLRequest = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        let connection: NSURLConnection = NSURLConnection(request: request as URLRequest, delegate: self, startImmediately: false)!
        
        return connection
    }
    
//    func signup(email: String, name: String) {
//        let connection = doPost("/api/v1/teams/signup", data: JSON(["email": email, "name" : name]))
//        connection.start()
//    }
    
//    func findTeams(email: String) {
//        let connection = doPost("/api/v1/teams/email_teams", data: JSON(["email": email]))
//        connection.start()
//    }
    
    func attachDeviceId() {
        let connection = doPost(MattermostApi.API_ROUTE + "/users/attach_device", data: JSON(["device_id": "apple:" + Utils.getProp(DEVICE_TOKEN)]))
        connection.start()
    }
    
    func getInitialLoad() {
        let connection = doGet(MattermostApi.API_ROUTE + "/users/initial_load")
        connection.start()
    }
    
//    func findTeamByName(name: String) {
//        let connection = doPost("/api/v1/teams/find_team_by_name", data: JSON(["name": name]))
//        connection.start()
//    }
    
//    func login(email: String, password: String) {
//        let defaults = NSUserDefaults.standardUserDefaults()
//        let teamName = defaults.stringForKey(CURRENT_TEAM_NAME)
//        var json :JSON = ["name":teamName!]
//        json["email"] = JSON(email)
//        json["password"] = JSON(password)
//        json["device_id"] = JSON("apple:" + Utils.getProp(DEVICE_TOKEN))
//        let connection = doPost("/api/v1/users/login", data: json)
//        connection.start()
//    }
    
//    func forgotPassword(email: String) {
//        let defaults = NSUserDefaults.standardUserDefaults()
//        let teamName = defaults.stringForKey(CURRENT_TEAM_NAME)
//        var json :JSON = ["name":teamName!]
//        json["email"] = JSON(email)
//        let connection = doPost("/api/v1/users/send_password_reset", data: json)
//        connection.start()
//    }
    
    func connection(_ connection: NSURLConnection!, didFailWithError error: NSError!) {
        statusCode = error.code
        print("Error: statusCode=\(statusCode) data=\(error.localizedDescription)")
        delegate?.didRecieveError("\(error.localizedDescription) [\(statusCode)]")
    }
    
    func connection(_ didReceiveResponse: NSURLConnection!, didReceiveResponse response: URLResponse!) {
        statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
        self.data = NSMutableData()
        
        let mmsid = Utils.getCookie(MATTERM_TOKEN)
        Utils.setProp(MATTERM_TOKEN, value: mmsid)
        print(mmsid)
        if (mmsid == "") {
            Utils.setProp(CURRENT_USER, value: "")
            Utils.setProp(MATTERM_TOKEN, value: "")
        }
    }

    func connection(_ connection: NSURLConnection, canAuthenticateAgainstProtectionSpace protectionSpace: URLProtectionSpace?) -> Bool
    {
        return protectionSpace?.authenticationMethod == NSURLAuthenticationMethodServerTrust
    }
    
    func connection(_ connection: NSURLConnection, didReceiveAuthenticationChallenge challenge: URLAuthenticationChallenge?)
    {
        if challenge?.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust
        {
            let credentials = URLCredential(trust: challenge!.protectionSpace.serverTrust!)
            challenge!.sender!.use(credentials, for: challenge!)
        }
        
        challenge?.sender!.continueWithoutCredential(for: challenge!)
    }
    
    func connection(_ connection: NSURLConnection!, didReceiveData data: Data!) {
        self.data.append(data)
    }
    
    func connectionDidFinishLoading(_ connection: NSURLConnection!) {
        let json = JSON(data: data as Data)
        
        if (statusCode == 200) {
            delegate?.didRecieveResponse(json)
        } else {
            let datastring = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)
            print("Error: statusCode=\(statusCode) data=\(datastring)")
            
            if let message = json["message"].string {
                delegate?.didRecieveError(message)
            } else {
                delegate?.didRecieveError(NSLocalizedString("UNKOWN_ERR", comment: "An unknown error has occured. (-1)"))
            }
        }
    }
}

