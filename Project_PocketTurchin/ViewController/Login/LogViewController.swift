//
//  LoginViewController.swift
//  Project_PocketTurchin
//
//  Created by 周元博 on 1/5/21.
//

import UIKit

class LogViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginAsGuestButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
    }
    
    func setUpElements() {
        Utilities.styleFilledButton(signUpButton)
        Utilities.styleHollowButton(loginButton)
        Utilities.styleHollowButton(loginAsGuestButton)
    }
    
    @IBAction func loginAsGuestTapped(_ sender: UIButton) {
        UserDefaults.standard.set(true, forKey: "guest")
        transitionToHome()
    }
    
    func transitionToHome() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let homeVC = storyBoard.instantiateViewController(identifier: "homeVC")
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(homeVC, options: .transitionFlipFromLeft)
        
    }
}
