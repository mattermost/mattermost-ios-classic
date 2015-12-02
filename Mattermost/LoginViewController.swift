// Copyright (c) 2015 Mattermost, Inc. All Rights Reserved.
// See License.txt for license information.

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, MattermostApiProtocol  {
    
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var teamTitle: UINavigationItem!
    @IBOutlet weak var proceedButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    var api: MattermostApi = MattermostApi()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        api.delegate = self
        
        proceedButton.layer.borderColor = proceedButton.titleLabel?.textColor.CGColor
        proceedButton.layer.borderWidth = 1.0
        proceedButton.layer.cornerRadius = 3.0
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let teamName = defaults.stringForKey(CURRENT_TEAM_NAME)
        teamTitle.title = teamName
                
        emailField.text = defaults.stringForKey(CURRENT_USER_EMAIL)
        
        let type: UIUserNotificationType = [UIUserNotificationType.Badge, UIUserNotificationType.Alert, UIUserNotificationType.Sound];
        let setting = UIUserNotificationSettings(forTypes: type, categories: nil);
        UIApplication.sharedApplication().registerUserNotificationSettings(setting);
        UIApplication.sharedApplication().registerForRemoteNotifications();
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        emailField.resignFirstResponder()
        api.login(emailField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).lowercaseString, password: passwordField.text!)
        return true
    }
    
    @IBAction func proceedClick(sender: AnyObject) {
        api.login(emailField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).lowercaseString, password: passwordField.text!)
    }
    
    @IBAction func dismissKeyboard(sender: AnyObject) {
        emailField.resignFirstResponder()
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func didRecieveResponse(results: JSON) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(results["email"].string, forKey: CURRENT_USER_EMAIL)
        passwordField.text = ""
        
        self.performSegueWithIdentifier("home_view", sender: self)
    }
    
    func didRecieveError(var message: String) {
        if (message == "We couldn't find the existing account") {
            emailField.layer.borderColor = UIColor.redColor().CGColor
            passwordField.layer.borderColor = UIColor.lightGrayColor().CGColor
        }
        else if (message == "Either user id or team name and user email must be provided") {
            emailField.layer.borderColor = UIColor.redColor().CGColor
            passwordField.layer.borderColor = UIColor.lightGrayColor().CGColor
            message = "Email address must be provided"
        } else {
            passwordField.layer.borderColor = UIColor.redColor().CGColor
            emailField.layer.borderColor = UIColor.lightGrayColor().CGColor
        }
        
        Utils.HandleUIError(message, label: errorLabel)
    }
}
