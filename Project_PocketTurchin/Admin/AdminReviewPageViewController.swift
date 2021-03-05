//
//  AdminReviewPageViewController.swift
//  Project_PocketTurchin
//
//  Created by 周元博 on 3/4/21.
//

import UIKit

class AdminReviewPageViewController: UIViewController {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var startDateLabel: UILabel!
    @IBOutlet var endDateLabel: UILabel!
    @IBOutlet var galleryLabel: UILabel!
    @IBOutlet var backToModifyButton: UIButton!
    @IBOutlet var confirmButton: UIButton!
    
    var e_title: String = ""
    var e_author: String = ""
    var e_startDate: String = ""
    var e_endDate: String = ""
    var e_gallery: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    @IBAction func backWasTapped(_ sender: UIButton) {
        UserDefaults.standard.setValue(true, forKey: "needReview")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmWasTapped(_ sender: UIButton) {
        UserDefaults.standard.setValue(false, forKey: "needReview")
        self.dismiss(animated: true, completion: nil)
    }
    
  
    func setUp() {
        titleLabel.text = "Title: \(e_title)"
        authorLabel.text = "Author: \(e_author)"
        startDateLabel.text = "Start_Date: \(e_startDate)"
        endDateLabel.text = "End_Date: \(e_endDate)"
        galleryLabel.text = "Gallery: \(e_gallery)"
        Utilities.styleFilledButton(backToModifyButton)
        Utilities.styleFilledButton(confirmButton)
    }
}
