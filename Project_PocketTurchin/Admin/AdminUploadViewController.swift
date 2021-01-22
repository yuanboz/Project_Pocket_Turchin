//
//  AdminUploadViewController.swift
//  Project_PocketTurchin
//
//  Created by 周元博 on 1/7/21.
//

import UIKit
import FirebaseStorage
import Firebase
import FirebaseDatabase

class AdminUploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var uploadButton: UIButton!
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var authorTextField: UITextField!
    @IBOutlet var startDataTextField: UITextField!
    @IBOutlet var endDateTextField: UITextField!
    @IBOutlet var galleryTextField: UITextField!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var coverImageView: UIImageView!
    
    private let datebase = Database.database().reference()
    
    var coverImgUrl: String = ""
    var exhibitionTitle: String = ""
    var exhibitionAuthor: String = ""
    var exhibitionStartDate: String = ""
    var exhibitionEndDate: String = ""
    var exhibitionGallery: String = ""
    
    
    private let storage = Storage.storage().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
    }
    
    func setUpElements() {
        Utilities.styleFilledButton(uploadButton)
        Utilities.styleFilledButton(submitButton)
        Utilities.styleTextField(titleTextField)
        Utilities.styleTextField(authorTextField)
        Utilities.styleTextField(startDataTextField)
        Utilities.styleTextField(endDateTextField)
        Utilities.styleTextField(galleryTextField)
    }
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        if textFieldValidate() {
            uploadToFirebase()
        }
    }
    
    @IBAction func uploadButtonTapped() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        guard let imageData = image.pngData() else { return }
        
        let imageName = NSUUID().uuidString
        let ref = storage.child("coverImg/\(imageName).png")
        
        ref.putData(imageData, metadata: nil) { ( _, err) in
            guard err == nil else {
                print("Failed to upload")
                return
            }
            ref.downloadURL { (url, err) in
                guard let url = url, err == nil else { return }

                let urlString = url.absoluteString
                self.coverImgUrl = urlString
            }
        }
        
        DispatchQueue.main.async {
            self.coverImageView.image = image
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func textFieldValidate() -> Bool {
        if titleTextField.text != nil && authorTextField.text != nil && startDataTextField.text != nil && endDateTextField.text != nil && galleryTextField.text != nil {
            exhibitionTitle = titleTextField.text!
            exhibitionAuthor = authorTextField.text!
            exhibitionStartDate = startDataTextField.text!
            exhibitionEndDate = endDateTextField.text!
            exhibitionGallery = galleryTextField.text!
            return true
        } else {
            errorLabel.alpha = 1
            errorLabel.text = "Please fill all the fields."
            return false
        }
    }
    
    func uploadToFirebase() {
        let ref = datebase.child("exhibitions").child(exhibitionTitle)
        let values = ["exhibitionTitle": exhibitionTitle,
                      "exhibitionAuthor": exhibitionAuthor,
                      "exhibitionStartDate": exhibitionStartDate,
                      "exhibitionEndDate": exhibitionEndDate,
                      "exhibitionGallery": exhibitionGallery,
                      "exhibitionCoverImg": coverImgUrl]
        ref.updateChildValues(values) { (err, ref) in
            if err != nil {
                print(err!)
                return
            }
        }
        normalAlert(title: "Upload Successfully", message: "Exhibition \(exhibitionTitle) has been uploaded.", actionTitle: "OK")
        self.titleTextField.text = ""
        self.authorTextField.text = ""
        self.startDataTextField.text = ""
        self.endDateTextField.text = ""
        self.galleryTextField.text = ""
    }
    
    func normalAlert(title: String, message: String, actionTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: actionTitle, style: .default, handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}
