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
        
        resetButton.layer.borderColor = resetButton.titleLabel?.textColor.CGColor
        resetButton.layer.borderWidth = 1.0
        resetButton.layer.cornerRadius = 3.0
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        emailField.resignFirstResponder()
//        api.forgotPassword(emailField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).lowercaseString)
        return true
    }
    
    @IBAction func dismissKeyboard(sender: AnyObject) {
        emailField.resignFirstResponder()
    }
    
    @IBAction func resetClick(sender: AnyObject) {
//        api.forgotPassword(emailField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).lowercaseString)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func didRecieveResponse(results: JSON) {
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }
    }
    
    func didRecieveError(message: String) {
        Utils.HandleUIError(message, label: errorLabel)
        emailField.layer.borderColor = UIColor.redColor().CGColor
    }
}
