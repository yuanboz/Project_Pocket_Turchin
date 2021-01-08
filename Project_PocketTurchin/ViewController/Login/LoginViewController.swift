//
//  LoginViewController.swift
//  Project_PocketTurchin
//
//  Created by 周元博 on 1/5/21.
//

import UIKit
import FirebaseAuth
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
    }
    
    func setUpElements() {
        // Hide the error label
        errorLabel.alpha = 0
        
        // Style the elements
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(loginButton)
    }
    
    func validateFields() -> String? {
        
        // Check if all fields are filled
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all fields."
        }
        return nil
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        // Check the input
        let error = validateFields()
        if error != nil {
            self.errorLabel.text = error
            self.errorLabel.alpha = 1
        } else {
            // Create cleaned versions of the data
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
            // Signing in the user
            Auth.auth().signIn(withEmail: email, password: password) { (res, err) in
                if err != nil {
                    self.errorLabel.text = err!.localizedDescription
                    self.errorLabel.alpha = 1
                } else {
                    // Save username and user type to UserDefaults
                    let defaults = UserDefaults.standard
                    let uid = res!.user.uid
                    if uid == "o5V6LyYCVacCRJXUK4ExLMKjGTQ2" {
                        // 0 means login as admin
                        defaults.set(0, forKey: "users")
                    } else {
                        // 1 means login as users
                        defaults.set(1, forKey: "users")
                    }
                    let db = Firestore.firestore()
                    db.collection("users").whereField("uid",isEqualTo: uid).getDocuments { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for doc in querySnapshot!.documents {
                                let data = doc.data()
                                let firstName = data["firstName"] as! String
                                let lastName = data["lastName"] as! String
                                let userName = firstName + lastName.dropLast(lastName.count - 1)
                        
                                defaults.set(userName,forKey: "username")
                            }
                        }
                    }
                    
                    //Transition to the home screen
                    Utilities.transitionToHome()
                }
            
            }
        }
    }
    
}
