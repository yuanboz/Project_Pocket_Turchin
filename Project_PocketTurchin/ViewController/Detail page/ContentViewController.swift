//
//  ContentViewController.swift
//  Project_PocketTurchin
//
//  Created by 周元博 on 1/11/21.
//

import UIKit

class ContentViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var exhibitionTitleLabel: UILabel!
    
    @IBOutlet var exhibitionAuthorLabel: UILabel!
    
    @IBOutlet var exhibitionDateLabel: UILabel!
    
    @IBOutlet var likedButton: UIButton!
    
    @IBOutlet var exhibitionDescriptionTextView: UITextView!
    
    @IBOutlet var slideCollectionView: UICollectionView!
    
    var exhibitionTitle: String?
    
    var exhibitionDate: String?
    
    var exhibitionAuthor: String?
    
    var liked: Bool = false
    
    let cellScale: CGFloat = 0.6

    override func viewDidLoad() {
        super.viewDidLoad()
        slideCollectionView.delegate = self
        slideCollectionView.dataSource = self
        setUpInfo()

        let screenSize = UIScreen.main.bounds.size
        let cellWidth = floor(screenSize.width * cellScale)
        let cellHeight = floor(screenSize.height * cellScale)
        let insertX = (view.bounds.width - cellWidth) / 2.0
        let insertY = (view.bounds.height - cellHeight) / 2.0
        
        let layout = slideCollectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        slideCollectionView.contentInset = UIEdgeInsets(top: insertY, left: insertX, bottom: insertY, right: insertX)
        
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
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: slideCollectionView.frame.width, height: slideCollectionView.frame.height)
//    }

}
