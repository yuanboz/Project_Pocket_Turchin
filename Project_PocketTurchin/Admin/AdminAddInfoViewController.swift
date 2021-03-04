//
//  AdminAddInfoViewController.swift
//  Project_PocketTurchin
//
//  Created by 周元博 on 2/17/21.
//

import UIKit
import FirebaseDatabase

class AdminAddInfoViewController: UIViewController {

    @IBOutlet var newEventTitleLabel: UILabel!
    @IBOutlet var uploadButton: UIButton!
    
    var newEventTitle: String = ""
    var briefDescription: String = ""
    var AbouttheAuthor: String = ""
    
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var aboutAuthorTextView: UITextView!
    
    private var database = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        newEventTitleLabel.text = newEventTitle
        Utilities.styleHollowButton(uploadButton)
    }
    @IBAction func uploadButtonWasTapped(_ sender: UIButton) {
        briefDescription = descriptionTextView.text
        AbouttheAuthor = aboutAuthorTextView.text
        uploadToFirebase()
    }
    
    func uploadToFirebase() {
        let ref = database.child("exhibitions").child(newEventTitle)
        let values = ["exhibitionDescription": briefDescription,
                      "aboutAuthor": AbouttheAuthor]
        ref.updateChildValues(values) { (err,ref) in
            if err != nil {
                print(err!)
                return
            }
        }
    }
    

}
