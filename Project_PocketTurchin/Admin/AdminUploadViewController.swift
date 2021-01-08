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
    @IBOutlet var dateTextField: UITextField!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var coverImageView: UIImageView!
    
    private let datebase = Database.database().reference()
    
    var coverImgUrl: String = ""
    var artTitle: String = ""
    var artDate: String = ""
    
    private let storage = Storage.storage().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
    }
    
    func setUpElements() {
        Utilities.styleFilledButton(uploadButton)
        Utilities.styleFilledButton(submitButton)
        Utilities.styleTextField(dateTextField)
        Utilities.styleTextField(titleTextField)
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
        if titleTextField.text != nil && dateTextField.text != nil {
            artTitle = titleTextField.text!
            artDate = dateTextField.text!
            return true
        } else {
            errorLabel.alpha = 1
            errorLabel.text = "Please fill all the fields."
            return false
        }
    }
    
    func uploadToFirebase() {
//        let db = Firestore.firestore()
//        db.collection("exhibitions").document(artTitle).setData(["exhibitionTitle":artTitle,"exhibitionDate":artDate,"exhibitionCoverImg": coverImgUrl])
        
        let ref = datebase.child("exhibitions").child(artTitle)
        let values = ["exhibitionTitle": artTitle,"exhibitionDate": artDate, "exhibitionCoverImg": coverImgUrl]
        ref.updateChildValues(values) { (err, ref) in
            if err != nil {
                print(err!)
                return
            }
        }
        normalAlert(title: "Upload Successfully", message: "Exhibition \(artTitle) has been uploaded.", actionTitle: "OK")
        self.titleTextField.text = ""
        self.dateTextField.text = ""
    }
    
    func normalAlert(title: String, message: String, actionTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: actionTitle, style: .default, handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}
