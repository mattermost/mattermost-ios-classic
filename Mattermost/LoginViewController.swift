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
        
        proceedButton.layer.borderColor = proceedButton.titleLabel?.textColor.cgColor
        proceedButton.layer.borderWidth = 1.0
        proceedButton.layer.cornerRadius = 3.0
        
        let defaults = UserDefaults.standard
        let teamName = defaults.string(forKey: CURRENT_TEAM_NAME)
        teamTitle.title = teamName
                
        emailField.text = defaults.string(forKey: CURRENT_USER_EMAIL)
        
        let type: UIUserNotificationType = [UIUserNotificationType.badge, UIUserNotificationType.alert, UIUserNotificationType.sound];
        let setting = UIUserNotificationSettings(types: type, categories: nil);
        UIApplication.shared.registerUserNotificationSettings(setting);
        UIApplication.shared.registerForRemoteNotifications();
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailField.resignFirstResponder()
//        api.login(emailField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).lowercaseString, password: passwordField.text!)
        return true
    }
    
    @IBAction func proceedClick(_ sender: AnyObject) {
//        api.login(emailField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).lowercaseString, password: passwordField.text!)
    }
    
    @IBAction func dismissKeyboard(_ sender: AnyObject) {
        emailField.resignFirstResponder()
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func didRecieveResponse(_ results: JSON) {
        let defaults = UserDefaults.standard
        defaults.set(results["email"].string, forKey: CURRENT_USER_EMAIL)
        passwordField.text = ""
        
        self.performSegue(withIdentifier: "home_view", sender: self)
    }
    
    func didRecieveError(_ message: String) {
        var message = message
        if (message == "We couldn't find the existing account") {
            emailField.layer.borderColor = UIColor.red.cgColor
            passwordField.layer.borderColor = UIColor.lightGray.cgColor
        }
        else if (message == "Either user id or team name and user email must be provided") {
            emailField.layer.borderColor = UIColor.red.cgColor
            passwordField.layer.borderColor = UIColor.lightGray.cgColor
            message = "Email address must be provided"
        } else {
            passwordField.layer.borderColor = UIColor.red.cgColor
            emailField.layer.borderColor = UIColor.lightGray.cgColor
        }
        
        Utils.HandleUIError(message, label: errorLabel)
    }
}
