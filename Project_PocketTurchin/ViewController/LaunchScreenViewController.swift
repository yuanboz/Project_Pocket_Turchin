//
//  LaunchScreenViewController.swift
//  Project_PocketTurchin
//
//  Created by 周元博 on 1/5/21.
//

import UIKit

class LaunchScreenViewController: UIViewController {

    private let imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 360, height: 309))
        imageView.image = UIImage(named: "launchLogo")
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.center = view.center
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0, execute: {
            self.animate()
        })
    }

    private func animate() {
        UIView.animate(withDuration: 1.0, animations: {
            let size = self.view.frame.width * 3
            let diffX = size - self.view.frame.size.width
            let diffY = self.view.frame.size.height - size
            
            self.imageView.frame = CGRect(
                x: -(diffX/2),
                y: diffY/2,
                width: size,
                height: size
            )
            
            UIView.animate(withDuration: 1.5, animations: {
                self.imageView.alpha = 0
            }, completion: { done in
                if done {
                    UserDefaults.standard.set("guest",forKey: "username")
                    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                    let homeVC = storyBoard.instantiateViewController(identifier: "homeVC")
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(homeVC, options: .transitionCrossDissolve)
                }
            })
        })
    }
}
