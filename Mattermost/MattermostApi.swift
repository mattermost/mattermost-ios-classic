// Copyright (c) 2015 Mattermost, Inc. All Rights Reserved.
// See License.txt for license information.

import Foundation
import UIKit

protocol MattermostApiProtocol {
    func didRecieveResponse(_ result: JSON)
    func didRecieveError(_ message: String)
}

open class MattermostApi: NSObject {
    
    static let API_ROUTE_V4 = "/api/v4"
    static let API_ROUTE_V3 = "/api/v3"
    static let API_ROUTE = API_ROUTE_V4
    
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
        
        if (url != nil && (url!).count > 0) {
            baseUrl = url!
        }
    }
    
    func getPing() {
        return getPing(versionRoute: MattermostApi.API_ROUTE)
    }
    
    func getPing(versionRoute: String) {
        var endpoint: String = baseUrl + versionRoute
        
        if (versionRoute == MattermostApi.API_ROUTE_V3) {
            endpoint += "/general/ping"
        } else {
            endpoint += "/system/ping"
        }
        
        print(endpoint)
        guard let url = URL(string: endpoint) else {
            print("Error cannot create URL")
            return
        }
        
        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            
            var code = 0
            if (response as? HTTPURLResponse) != nil {
                code = (response as! HTTPURLResponse).statusCode
            }
            
            guard error == nil else {
                print(error!)
                print("Error: statusCode=\(code) data=\(error!.localizedDescription)")
                DispatchQueue.main.async {
                    self.delegate?.didRecieveError("\(error!.localizedDescription) [\(code)]")
                }
                
                return
            }
            
            guard let responseData = data else {
                print("Error: did not receive data")
                DispatchQueue.main.async {
                    self.delegate?.didRecieveError("Did not receive data from the server.")
                }
                
                return
            }
            
            let json = JSON(data: responseData as Data)

            if (code == 200) {
                print("Found API version " + versionRoute)
                Utils.setProp(API_ROUTE_PROP, value: versionRoute)

                DispatchQueue.main.async {
                    self.delegate?.didRecieveResponse(json)
                }
            } else if (code == 404) {
                print("Couldn't find V4 API falling back to V3")
                
                if (versionRoute != MattermostApi.API_ROUTE_V3) {
                    return self.getPing(versionRoute: MattermostApi.API_ROUTE_V3)
                } else {
                    DispatchQueue.main.async {
                        self.delegate?.didRecieveError("Couldn't find the correct Mattermost server version.")
                    }
                }
            } else {
                let datastring = NSString(data: responseData as Data, encoding: String.Encoding.utf8.rawValue)
                print("Error: statusCode=\(code) data=\(datastring!)")

                if let message = json["message"].string {
                    DispatchQueue.main.async {
                        self.delegate?.didRecieveError(message)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.delegate?.didRecieveError(NSLocalizedString("UNKOWN_ERR", comment: "An unknown error has occured (-1)"))
                    }
                }
            }
        }
        
        task.resume()
    }
    
    func attachDeviceId() {
        var endpoint: String = baseUrl + Utils.getProp(API_ROUTE_PROP)
        
        if (Utils.getProp(API_ROUTE_PROP) == MattermostApi.API_ROUTE_V3) {
            endpoint += "/users/attach_device"
        } else {
            endpoint += "/users/sessions/device"
        }
        
        print(endpoint)
        guard let url = URL(string: endpoint) else {
            print("Error cannot create URL")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        if (Utils.getProp(API_ROUTE_PROP) == MattermostApi.API_ROUTE_V3) {
            urlRequest.httpMethod = "POST"
        } else {
            urlRequest.httpMethod = "PUT"
        }
        
        urlRequest.addValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        urlRequest.httpBody = try! JSON(["device_id": "apple:" + Utils.getProp(DEVICE_TOKEN)]).rawData()
        let session = URLSession.shared
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            
            var code = 0
            if (response as? HTTPURLResponse) != nil {
                code = (response as! HTTPURLResponse).statusCode
            }
            
            guard error == nil else {
                print(error!)
                print("Error: statusCode=\(code) data=\(error!.localizedDescription)")
                
                return
            }
        }
        
        task.resume()
    }
    
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
            print("Error: statusCode=\(statusCode) data=\(datastring!)")
            
            if let message = json["message"].string {
                delegate?.didRecieveError(message)
            } else {
                delegate?.didRecieveError(NSLocalizedString("UNKOWN_ERR", comment: "An unknown error has occured. (-1)"))
            }
        }
    }
}

