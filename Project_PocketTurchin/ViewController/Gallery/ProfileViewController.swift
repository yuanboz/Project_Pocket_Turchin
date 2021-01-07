//
//  ProfileViewController.swift
//  Project_PocketTurchin
//
//  Created by 周元博 on 1/6/21.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var imaProfile: UIImageView!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var adminButton: UIButton!
    var users = UserDefaults.standard.integer(forKey: "users")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkUser(users)
        Utilities.styleHollowButton(signOutButton)
    }
    
    func checkUser(_ users: Int) {
        print(users)
        switch users {
        case 0:
            userNameLabel.text = UserDefaults.standard.value(forKey: "username") as? String
            adminButton.alpha = 1
            adminButton.isUserInteractionEnabled = true
        case 2:
            userNameLabel.text = "Guest"
        default:
            userNameLabel.text = UserDefaults.standard.value(forKey: "username") as? String
        }
    }
    
    @IBAction func signOutButtonTapped(_ sender: UIButton) {
        logoutUser()
    }
    
    func logoutUser() {
        if users == 2 {
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            Utilities.transitionToLogin()
        } else {
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            do {
                try Auth.auth().signOut()
            } catch {
                print("aleardy logged out")
            }
            Utilities.transitionToLogin()
        }
    }
    
    @IBAction func adminButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "adminVC", sender: sender)
    }
    
    

}
