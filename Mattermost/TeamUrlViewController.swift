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
        Utils.setTeamUrl(urlField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).lowercaseString)
        api.initBaseUrl();
        let defaults = NSUserDefaults.standardUserDefaults()
        let teamName = defaults.stringForKey(CURRENT_TEAM_NAME)
        
        if (teamName == nil) {
            Utils.HandleUIError(NSLocalizedString("TEAM_URL_NOT_FOUND", comment: "Team URL not found"), label: errorLabel)
            urlField.layer.borderColor = UIColor.redColor().CGColor
            
        } else {
            api.findTeamByName(teamName!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        urlField.delegate = self
        api.delegate = self
        
        proceedButton.layer.borderColor = proceedButton.titleLabel?.textColor.CGColor
        proceedButton.layer.borderWidth = 1.0
        proceedButton.layer.cornerRadius = 3.0
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
        if ("true" == results.rawString()) {
            self.performSegueWithIdentifier("home_view", sender: self)
        } else {
            Utils.HandleUIError(NSLocalizedString("SIGNIN_NO_TEAM", comment: "The team does not appear to exist."), label: errorLabel)
            urlField.layer.borderColor = UIColor.redColor().CGColor
        }
    }
        
    func didRecieveError(message: String) {
        if (message.containsString("-1003")) {
            Utils.HandleUIError(NSLocalizedString("TEAM_URL_NOT_FOUND", comment: "Team URL not found"), label: errorLabel)
        } else if (message.containsString("-1002")) {
            Utils.HandleUIError(NSLocalizedString("TEAM_URL_NOT_FOUND", comment: "Team URL not found"), label: errorLabel)
        } else if (message.containsString("Invalid domain parameter")) {
            Utils.HandleUIError(NSLocalizedString("TEAM_URL_NOT_FOUND", comment: "Team URL not found"), label: errorLabel)
        } else if (message.containsString("(-1)")) {
            Utils.HandleUIError(NSLocalizedString("TEAM_URL_NOT_FOUND", comment: "Team URL not found"), label: errorLabel)
        } else if (message.containsString("UNKNOWN_ERR")) {
            Utils.HandleUIError(NSLocalizedString("TEAM_URL_NOT_FOUND", comment: "Team URL not found"), label: errorLabel)
        } else {
            Utils.HandleUIError(message, label: errorLabel)
        }
        
        urlField.layer.borderColor = UIColor.redColor().CGColor
    }
}
