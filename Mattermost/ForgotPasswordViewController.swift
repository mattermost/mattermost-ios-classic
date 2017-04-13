// Copyright (c) 2015 Mattermost, Inc. All Rights Reserved.
// See License.txt for license information.

import UIKit

class ForgotPasswordViewController: UIViewController, UITextFieldDelegate, MattermostApiProtocol  {
    
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    
    var api: MattermostApi = MattermostApi()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        api.delegate = self
        
        resetButton.layer.borderColor = resetButton.titleLabel?.textColor.cgColor
        resetButton.layer.borderWidth = 1.0
        resetButton.layer.cornerRadius = 3.0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailField.resignFirstResponder()
//        api.forgotPassword(emailField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).lowercaseString)
        return true
    }
    
    @IBAction func dismissKeyboard(_ sender: AnyObject) {
        emailField.resignFirstResponder()
    }
    
    @IBAction func resetClick(_ sender: AnyObject) {
//        api.forgotPassword(emailField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).lowercaseString)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func didRecieveResponse(_ results: JSON) {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    
    func didRecieveError(_ message: String) {
        Utils.HandleUIError(message, label: errorLabel)
        emailField.layer.borderColor = UIColor.red.cgColor
    }
}
