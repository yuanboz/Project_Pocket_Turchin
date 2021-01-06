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
    var guest = UserDefaults.standard.bool(forKey: "guest")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameLabel.text = checkGuest(guest)
        Utilities.styleHollowButton(signOutButton)
    }
    
    func checkGuest(_ guest: Bool) -> String? {
        if guest == true {
            return "Guest"
        } else {
            return UserDefaults.standard.value(forKey: "username") as? String
        }
    }
    
    @IBAction func signOutButtonTapped(_ sender: UIButton) {
        logoutUser()
    }
    
    func logoutUser() {
        if guest == true {
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
    

}
