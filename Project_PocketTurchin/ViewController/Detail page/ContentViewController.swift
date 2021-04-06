//
//  ContentViewController.swift
//  Project_PocketTurchin
//
//  Created by 周元博 on 1/11/21.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class ContentViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var exhibitionTitleLabel: UILabel!
    @IBOutlet var exhibitionAuthorLabel: UILabel!
    @IBOutlet var exhibitionDateLabel: UILabel!
    @IBOutlet var likedButton: UIButton!
    @IBOutlet var slideCollectionView: UICollectionView!
    @IBOutlet var exhibitionDescriptionTextView: UITextView!
    @IBOutlet var aboutAuthorTextView: UITextView!
    @IBOutlet var likeLabel: UILabel!
    
    private let database = Database.database().reference()
    
    var exhibitionTitle: String?
    var exhibitionDate: String?
    var exhibitionAuthor: String?
    var exhibitionDescription: String?
    var exhibitionAboutAuthor: String?
    var exhibitionLiked: Int = 0
    
    var liked: Bool = false
    var likedStatus: Bool = false
    
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
        
        let username = UserDefaults.standard.value(forKey: "username") as! String
        print(username)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkLikeStatus()
    }
    
    func setUpInfo() {
        exhibitionTitle = UserDefaults.standard.value(forKey: "exhibitionTitle") as? String
        exhibitionDate = UserDefaults.standard.value(forKey: "exhibitionDate") as? String
        exhibitionAuthor = UserDefaults.standard.value(forKey: "exhibitionAuthor") as? String
        exhibitionTitleLabel.text = exhibitionTitle
        exhibitionDateLabel.text = exhibitionDate
        exhibitionAuthorLabel.text = exhibitionAuthor
    }
    
    func likedButtonAnimation() {
        updateLiked(like: liked)
    }
    
    @IBAction func likedButtonTapped(_ sender: UIButton) {
        likedButtonAnimation()
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
    }
    
    func updateLiked(like: Bool) {
        let ref = database.child("exhibitions").child(self.exhibitionTitle!)
        if like != true {
            liked = true
            likedButton.setImage(UIImage(named: "filledheart"), for: .normal)
            self.exhibitionLiked += 1
            self.likeLabel.text = String(self.exhibitionLiked)
            
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
            
            likedStatus = false
        }
        ref.updateChildValues(["liked":String(self.exhibitionLiked)])
        UserDefaults.standard.setValue(likedStatus, forKey: "likeStatus" + self.exhibitionTitle!)
    }
    
    func checkLikeStatus() {
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
