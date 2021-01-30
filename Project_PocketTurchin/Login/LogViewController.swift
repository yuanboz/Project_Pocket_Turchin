//
//  LoginViewController.swift
//  Project_PocketTurchin
//
//  Created by 周元博 on 1/5/21.
//

import UIKit
import AVKit

class LogViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginAsGuestButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    var videoPlayer: AVPlayer?
    var videoPlayerLayer:AVPlayerLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUpVideo()
    }
    
    func setUpElements() {
        Utilities.styleFilledButton(signUpButton)
        Utilities.styleHollowButton(loginButton)
        Utilities.styleHollowButton(loginAsGuestButton)
    }
    
    @IBAction func loginAsGuestTapped(_ sender: UIButton) {
        //2 means login as guest
        UserDefaults.standard.set(2, forKey: "users")
        Utilities.transitionToHome()
    }
    
    func setUpVideo() {
        // Get the path to the resource in the bundle
        let bundlePath = Bundle.main.path(forResource: "bgVideo", ofType: "mp4")
        
        guard bundlePath != nil else {
            return
        }
        
        // Create a URL from it
        let url = URL(fileURLWithPath: bundlePath!)
        
        // Create the video player item
        let item = AVPlayerItem(url: url)
        
        // Create the player
        videoPlayer = AVPlayer(playerItem: item)
        
        // Create the layer
        videoPlayerLayer = AVPlayerLayer(player: videoPlayer!)
        
        // Adjust the size and frame
        videoPlayerLayer?.frame = CGRect(x: -self.view.frame.size.width*1.5, y: 0, width: self.view.frame.size.width*4, height: self.view.frame.size.height)
        
        view.layer.insertSublayer(videoPlayerLayer!, at: 0)
        
        // Add it to the view and play it
        videoPlayer?.playImmediately(atRate: 0.7)
    }
    
}
