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
    @IBOutlet var adminBarItem: UIBarButtonItem!
    var users = UserDefaults.standard.integer(forKey: "users")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkUser(users)
        setUpNavigationImage()
        Utilities.styleHollowButton(signOutButton)
    }
    
    func setUpNavigationImage() {
        let logo = UIImage(named: "navigationBGImage.png")
        let imageView = UIImageView(image: logo)
        self.navigationItem.titleView = imageView
    }
    
    func checkUser(_ users: Int) {
        print(users)
        switch users {
        case 0:
            userNameLabel.text = UserDefaults.standard.value(forKey: "username") as? String
            adminButton.alpha = 1
            adminButton.isUserInteractionEnabled = true
            self.navigationItem.rightBarButtonItem = adminBarItem
            signOutButton.setTitle("Sign out", for: .normal)
            
        case 2:
            userNameLabel.text = "guest"
            signOutButton.setTitle("Login", for: .normal)
            self.navigationItem.rightBarButtonItem = adminBarItem
        default:
            userNameLabel.text = UserDefaults.standard.value(forKey: "username") as? String
            self.navigationItem.rightBarButtonItem = nil
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
    
    // Switch to admin mode
    @IBAction func adminButtonTapped(_ sender: UIButton) {
        let adminMode = UserDefaults.standard.bool(forKey: "adminMode")
        if adminMode != true {
            switchToAdminMode()
        } else {
            switchToUserMode()
        }
    }
    
    private func switchToAdminMode() {
        self.adminButton.setTitle("Switch to User mode", for: .normal)
        UserDefaults.standard.set(true, forKey: "adminMode")
        normalAlert(title: "Mode Switch", message: "You're now switch to Admin mode.", actionTitle: "OK")
    }
    
    private func switchToUserMode() {
        self.adminButton.setTitle("Switch to Admin mode", for: .normal)
        UserDefaults.standard.set(false, forKey: "adminMode")
        normalAlert(title: "Mode Switch", message: "You're now back to User mode.", actionTitle: "OK")
    }
    
    func normalAlert(title: String, message: String, actionTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: actionTitle, style: .default, handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
