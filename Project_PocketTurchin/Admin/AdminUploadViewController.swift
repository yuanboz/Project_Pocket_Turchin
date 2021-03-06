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

class AdminUploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIPickerViewDataSource,UIPickerViewDelegate {

    @IBOutlet var uploadButton: UIButton!
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var authorTextField: UITextField!
    @IBOutlet var startDataTextField: UITextField!
    @IBOutlet var endDateTextField: UITextField!
    @IBOutlet var galleryTextField: UITextField!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var coverImageView: UIImageView!
    @IBOutlet var moreInfoButton: UIButton!
    @IBOutlet var moreImageButton: UIButton!
    private var pickerView = UIPickerView()
    private var datePicker_start: UIDatePicker?
    private var datePicker_end: UIDatePicker?
    
    private let datebase = Database.database().reference()
    private let db = Firestore.firestore()
    
    let galleryList = ["Community Gallery","Gallery A", "Gallery B","Main Gallery","Mayer Gallery","Mezzanine Gallery"]
    
    var coverImgUrl: String = ""
    var exhibitionTitle: String = ""
    var exhibitionAuthor: String = ""
    var exhibitionStartDate: String = ""
    var exhibitionEndDate: String = ""
    var exhibitionGallery: String = ""
    var needReview: Bool = true
    
    private let storage = Storage.storage().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        galleryTextField.inputView = pickerView
        galleryTextField.textAlignment = .left
        pickerView.delegate = self
        pickerView.dataSource = self
        setUpElements()
        setupDatePicker()
    }
    
    
    func setupDatePicker() {
        datePicker_start = UIDatePicker()
        datePicker_start?.preferredDatePickerStyle = .wheels
        datePicker_start?.datePickerMode = .date
        
        datePicker_end = UIDatePicker()
        datePicker_end?.preferredDatePickerStyle = .wheels
        datePicker_end?.datePickerMode = .date
        
        datePicker_start?.addTarget(self, action: #selector(startDateChanged(datePicker:)), for: .valueChanged)
        datePicker_end?.addTarget(self, action: #selector(endDateChanged(datePicker:)), for: .valueChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        startDataTextField.inputView = datePicker_start
        endDateTextField.inputView = datePicker_end
    }
    
    @objc func startDateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        startDataTextField.text = dateFormatter.string(from: datePicker.date)
    }
    
    @objc func endDateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        endDateTextField.text = dateFormatter.string(from: datePicker.date)
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return galleryList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return galleryList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        galleryTextField.text = galleryList[row]
        galleryTextField.resignFirstResponder()
    }
    
    func setUpElements() {
        Utilities.styleFilledButton(uploadButton)
        Utilities.styleFilledButton(submitButton)
        Utilities.styleFilledButton(moreInfoButton)
        Utilities.styleFilledButton(moreImageButton)
        Utilities.styleTextField(titleTextField)
        Utilities.styleTextField(authorTextField)
        Utilities.styleTextField(startDataTextField)
        Utilities.styleTextField(endDateTextField)
        Utilities.styleTextField(galleryTextField)
    }
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        if UserDefaults.standard.value(forKey: "needReview") != nil {
            needReview = UserDefaults.standard.value(forKey: "needReview") as! Bool
        }
        if textFieldValidate() {
            if needReview == true {
                guard let vc = storyboard?.instantiateViewController(identifier: "reviewpage") as? AdminReviewPageViewController else { return }
                vc.e_title = exhibitionTitle
                vc.e_author = exhibitionAuthor
                vc.e_startDate = exhibitionStartDate
                vc.e_endDate = exhibitionEndDate
                vc.e_gallery = exhibitionGallery
                self.present(vc, animated: true, completion: nil)
            }
            if needReview == false{
                uploadToFirebase()
                clearData()
                UserDefaults.standard.setValue(true, forKey: "needReview")
            }
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
        if titleTextField.text != "" && authorTextField.text != "" && startDataTextField.text != "" && endDateTextField.text != "" && galleryTextField.text != "" {
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
        db.collection("gallery").document(exhibitionGallery.lowercased()).setData([exhibitionTitle: exhibitionStartDate + "-" + exhibitionEndDate], merge: true)
        let ref = datebase.child("exhibitions").child(exhibitionTitle as String)
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
    }
    
    func normalAlert(title: String, message: String, actionTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: actionTitle, style: .default, handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addInfoButtonWasTapped(_ sender: UIButton) {
        guard let vc = storyboard?.instantiateViewController(identifier: "addMoreInfo") as? AdminAddInfoViewController else { return }
        vc.newEventTitle = exhibitionTitle
        self.present(vc, animated: true, completion: nil)
    }
    
    func clearData() {
        titleTextField.text = ""
        authorTextField.text = ""
        startDataTextField.text = ""
        endDateTextField.text = ""
        galleryTextField.text = ""
    }
    
}
