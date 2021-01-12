//
//  ContentViewController.swift
//  Project_PocketTurchin
//
//  Created by 周元博 on 1/11/21.
//

import UIKit

class ContentViewController: UIViewController {
    
    @IBOutlet var exhibitionTitleLabel: UILabel!
    
    @IBOutlet var exhibitionAuthorLabel: UILabel!
    
    @IBOutlet var exhibitionDateLabel: UILabel!
    
    @IBOutlet var likedButton: UIButton!
    
    var exhibitionTitle: String?
    
    var exhibitionDate: String?
    
    var liked: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpInfo()
    }
    
    func setUpInfo() {
        exhibitionTitle = UserDefaults.standard.value(forKey: "exhibitionTitle") as? String
        exhibitionDate = UserDefaults.standard.value(forKey: "exhibitionDate") as? String
        exhibitionTitleLabel.text = exhibitionTitle
        exhibitionDateLabel.text = exhibitionDate
    }
    
    func likedButtonAnimation() {
        if liked != true {
            liked = true
            likedButton.setImage(UIImage(named: "filledheart"), for: .normal)
        } else {
            liked = false
            likedButton.setImage(UIImage(named: "hollowheart"), for: .normal)
        }
    }
    
    @IBAction func likedButtonTapped(_ sender: UIButton) {
        likedButtonAnimation()
    }

}
