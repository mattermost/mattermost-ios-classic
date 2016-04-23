// Copyright (c) 2015 Mattermost, Inc. All Rights Reserved.
// See License.txt for license information.

import UIKit

class TeamUrlViewController: UIViewController, UITextFieldDelegate, MattermostApiProtocol {

    @IBOutlet weak var urlField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var proceedButton: UIButton!
    
    var api: MattermostApi = MattermostApi()
    
    @IBAction func nextClick(sender: UIBarButtonItem) {
        doNext()
    }
    
    @IBAction func proceedClick(sender: AnyObject) {
        doNext()
    }
    
    func doNext() {
        let serverUrl = urlField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).lowercaseString
        
        if (serverUrl.characters.count == 0) {
            return
        }
        
        Utils.setServerUrl(serverUrl)
        print("here")
        api.initBaseUrl()
        api.getInitialLoad()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        urlField.delegate = self
        api.delegate = self
        
        proceedButton.layer.borderColor = proceedButton.titleLabel?.textColor.CGColor
        proceedButton.layer.borderWidth = 1.0
        proceedButton.layer.cornerRadius = 3.0
        
        Utils.setProp(CURRENT_USER, value: "")
        Utils.setProp(MATTERM_TOKEN, value: "")
        Utils.setProp(ATTACHED_DEVICE, value: "")
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        urlField.resignFirstResponder()
        doNext()
        return true
    }
    
    @IBAction func dismissKeyboard(sender: UITapGestureRecognizer) {
        urlField.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func didRecieveResponse(results: JSON) {
        
        var isValidServer = false
                
        if let version = results["client_cfg"]["Version"].string {
            if version.characters.count > 0 {
                isValidServer = true
            }
        }
    
        if (isValidServer) {
            self.performSegueWithIdentifier("home_view", sender: self)
        } else {
            Utils.HandleUIError(NSLocalizedString("SERVER_NOT_FOUND", comment: "We could not connect to the Mattermost server or the server running in an incompatible version."), label: errorLabel)
            urlField.layer.borderColor = UIColor.redColor().CGColor
        }
    }
        
    func didRecieveError(message: String) {
        if (message.containsString("-1003")) {
            Utils.HandleUIError(NSLocalizedString("SERVER_NOT_FOUND", comment: "We could not connect to the Mattermost server or the server running in an incompatible version."), label: errorLabel)
        } else if (message.containsString("-1002")) {
            Utils.HandleUIError(NSLocalizedString("SERVER_NOT_FOUND", comment: "We could not connect to the Mattermost server or the server running in an incompatible version.d"), label: errorLabel)
        } else if (message.containsString("Invalid domain parameter")) {
            Utils.HandleUIError(NSLocalizedString("SERVER_NOT_FOUND", comment: "We could not connect to the Mattermost server or the server running in an incompatible version."), label: errorLabel)
        } else if (message.containsString("(-1)")) {
            Utils.HandleUIError(NSLocalizedString("SERVER_NOT_FOUND", comment: "We could not connect to the Mattermost server or the server running in an incompatible version."), label: errorLabel)
        } else if (message.containsString("UNKNOWN_ERR")) {
            Utils.HandleUIError(NSLocalizedString("SERVER_NOT_FOUND", comment: "We could not connect to the Mattermost server or the server running in an incompatible version."), label: errorLabel)
        } else {
            Utils.HandleUIError(message, label: errorLabel)
        }
        
        urlField.layer.borderColor = UIColor.redColor().CGColor
    }
}
