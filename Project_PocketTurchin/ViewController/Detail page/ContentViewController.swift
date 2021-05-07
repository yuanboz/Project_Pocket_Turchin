//
//  ContentViewController.swift
//  Project_PocketTurchin
//
//  Created by 周元博 on 1/11/21.
//

import UIKit
import FirebaseDatabase
import Firebase

class ContentViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var exhibitionTitleLabel: UILabel!
    @IBOutlet var exhibitionAuthorLabel: UILabel!
    @IBOutlet var exhibitionDateLabel: UILabel!
    @IBOutlet var likedButton: UIButton!
    @IBOutlet var slideCollectionView: UICollectionView!
    @IBOutlet var exhibitionDescriptionTextView: UITextView!
    @IBOutlet var aboutAuthorTextView: UITextView!
    @IBOutlet var likeLabel: UILabel!
    @IBOutlet var commentButton: UIButton!
    @IBOutlet var commentTextField: UITextField!
    @IBOutlet var sendButton: UIButton!
    
    private let database = Database.database().reference()
    private let db = Firestore.firestore()
    
    var exhibitionTitle: String?
    var exhibitionDate: String?
    var exhibitionAuthor: String?
    var exhibitionDescription: String?
    var exhibitionAboutAuthor: String?
    var username: String = "guest"
    var exhibitionLiked: Int = 0
    var commentArray = [String]()
    
    var liked: Bool = false
    var likedStatus: Bool = false
    var likedExhibition = [String]()
    
    let cellScale: CGFloat = 0.6

    override func viewDidLoad() {
        super.viewDidLoad()
        slideCollectionView.delegate = self
        slideCollectionView.dataSource = self
        setUpInfo()
        fetchData()
        

        let screenSize = UIScreen.main.bounds.size
        let cellWidth = floor(screenSize.width * cellScale)
        let cellHeight = floor(screenSize.height * cellScale)
        let insertX = (view.bounds.width - cellWidth) / 2.0
        let insertY = (view.bounds.height - cellHeight) / 2.0
        
        let layout = slideCollectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        slideCollectionView.contentInset = UIEdgeInsets(top: insertY, left: insertX, bottom: insertY, right: insertX)
        print(username)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkLikeStatus()
    }

    
    func setUpInfo() {
        exhibitionTitle = UserDefaults.standard.value(forKey: "exhibitionTitle") as? String
        exhibitionDate = UserDefaults.standard.value(forKey: "exhibitionDate") as? String
        exhibitionAuthor = UserDefaults.standard.value(forKey: "exhibitionAuthor") as? String
        exhibitionTitleLabel.text = exhibitionTitle
        exhibitionDateLabel.text = exhibitionDate
        exhibitionAuthorLabel.text = exhibitionAuthor
        commentTextField.isHidden = true
        commentTextField.isUserInteractionEnabled = false
        Utilities.styleTextField(commentTextField)
        sendButton.isHidden = true
        sendButton.isUserInteractionEnabled = false
    }
    
    func likedButtonAnimation() {
        updateLiked(like: liked)
    }
    
    @IBAction func likedButtonTapped(_ sender: UIButton) {
        likedButtonAnimation()
    }
    
    @IBAction func commentButtonTapped(_ sender: UIButton) {
        if username == "guest" {
            let alert = UIAlertController(title: "No permission", message: "Guest cannot leave a comment", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            commentTextField.isHidden = false
            commentTextField.isUserInteractionEnabled = true
            sendButton.isHidden = false
            sendButton.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        if commentTextField.text == "" {
            let alert = UIAlertController(title: "Add a comment...", message: "Please leave a comment before post", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            self.commentArray.append(commentTextField.text!)
            db.collection("comments").document(exhibitionTitle!).setData([username: self.commentArray],merge: true)
            
            let alert = UIAlertController(title: "Post successfully", message: "You've posted 1 message successfully", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        // Clear the comment field
        commentTextField.text = ""
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = slideCollectionView.dequeueReusableCell(withReuseIdentifier: "contentviewcell", for: indexPath) as! ContentViewCollectionViewCell
        
        return cell
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let layout = self.slideCollectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        let roundedIndex = round(index)
        
        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: scrollView.contentInset.top)
        
        targetContentOffset.pointee = offset
    }
    
    func fetchData() {
        let ref = database.child("exhibitions").child(self.exhibitionTitle!)
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let description = value?["exhibitionDescription"] as! String
            let aboutauthor = value?["aboutAuthor"] as! String
            let like = value?["liked"] as! String
            self.exhibitionLiked = Int(like)!
            self.exhibitionDescription = description
            self.exhibitionDescriptionTextView.text = self.exhibitionDescription
            self.exhibitionAboutAuthor = aboutauthor
            self.aboutAuthorTextView.text = self.exhibitionAboutAuthor
            self.likeLabel.text = "\(self.exhibitionLiked)"
        }
        
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        db.collection("users").whereField("uid", isEqualTo: uid).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for doc in querySnapshot!.documents {
                    let data = doc.data()
                    guard let likedExhibition = data["liked"] as? [String] else { return }
                    self.likedExhibition = likedExhibition
                    print(self.likedExhibition)
                }
            }
        }
    
        username = (UserDefaults.standard.value(forKey: "username") as! String)
        let docRef = db.collection("comments").document(exhibitionTitle!)
        
        docRef.getDocument { (document, err) in
            if let doc = document {
                guard let data = doc.data() else { return }
                guard let comment = data[self.username] else { return }
                self.commentArray = comment as! [String]
                //print(self.commentArray)
            }
        }
    }
    
    func updateLiked(like: Bool) {
        let ref = database.child("exhibitions").child(self.exhibitionTitle!)
        if like != true {
            liked = true
            likedButton.setImage(UIImage(named: "filledheart"), for: .normal)
            self.exhibitionLiked += 1
            self.likeLabel.text = String(self.exhibitionLiked)
            
            self.likedExhibition.append(self.exhibitionTitle!)
            
            likedStatus = true
        } else {
            liked = false
            likedButton.setImage(UIImage(named: "hollowheart"), for: .normal)
            if (self.exhibitionLiked <= 1) {
                self.exhibitionLiked = 0
            } else {
                self.exhibitionLiked -= 1
            }
            self.likeLabel.text = String(self.exhibitionLiked)
            
            self.likedExhibition = self.likedExhibition.filter{$0 != self.exhibitionTitle!}
            
            likedStatus = false
        }
        ref.updateChildValues(["liked":String(self.exhibitionLiked)])
        if let uid = UserDefaults.standard.value(forKey: "uid") as? String {
            db.collection("users").document(uid).setData(["liked": self.likedExhibition],merge: true)
        }
        
        UserDefaults.standard.setValue(likedStatus, forKey: "likeStatus" + self.exhibitionTitle!)
    }
    
    func checkLikeStatus() {
      
        if username != "guest" {
            print("not guest")
            //print(self.likedExhibition)
            if self.likedExhibition.contains(self.exhibitionTitle!) {
                print("contains")
                liked = true
                likedButton.setImage(UIImage(named: "filledheart"), for: .normal)
            } else {
                print("not contains")
                liked = false
                likedButton.setImage(UIImage(named: "hollowheart"), for: .normal)
            }
        } else {
            if let status = UserDefaults.standard.value(forKey: "likeStatus" + self.exhibitionTitle!) {
                if status as! Bool == false {
                    liked = false
                    likedButton.setImage(UIImage(named: "hollowheart"), for: .normal)
                } else {
                    liked = true
                    likedButton.setImage(UIImage(named: "filledheart"), for: .normal)
                }
            }
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notificaiton: NSNotification) {
        if ((notificaiton.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y = 0
            }
        }
    }

}
