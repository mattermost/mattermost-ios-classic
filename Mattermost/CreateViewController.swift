// Copyright (c) 2015 Mattermost, Inc. All Rights Reserved.
// See License.txt for license information.

import UIKit

class CreateViewController: UIViewController, UITextFieldDelegate, MattermostApiProtocol  {

    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    var api: MattermostApi = MattermostApi()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        nameField.delegate = self
        api.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        emailField.resignFirstResponder()
        nameField.resignFirstResponder()
        api.signup(emailField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).lowercaseString, name: nameField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).lowercaseString)
        return true
    }
    
    @IBAction func dismissKeyboard(sender: AnyObject) {
        emailField.resignFirstResponder()
        nameField.resignFirstResponder()
    }

    @IBAction func sendClick(sender: AnyObject) {
        api.signup(emailField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).lowercaseString, name: nameField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).lowercaseString)
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
        Utils.HandleUIError(message, label: displayLabel)
    }
}
