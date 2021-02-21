//
//  AdminAddInfoViewController.swift
//  Project_PocketTurchin
//
//  Created by 周元博 on 2/17/21.
//

import UIKit

class AdminAddInfoViewController: UIViewController {

    @IBOutlet var newEventTitleLabel: UILabel!
    @IBOutlet var uploadButton: UIButton!
    
    var newEventTitle: String = ""
    var briefDescription: String = ""
    var AbouttheAuthor: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        newEventTitleLabel.text = newEventTitle
        Utilities.styleHollowButton(uploadButton)
    }
    

}
