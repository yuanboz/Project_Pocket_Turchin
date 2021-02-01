//
//  HomePageViewController.swift
//  Project_PocketTurchin
//
//  Created by 周元博 on 1/22/21.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase

class HomePageViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var slideCollectionView: UICollectionView!
    @IBOutlet var pageControl: UIPageControl!
    
    private let database = Database.database().reference()
    
    var currentExhibition = [Exhibition]()  // Store current exhibitions
    
    var currentIndex = 0
    var timer: Timer!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        slideCollectionView.delegate = self
        slideCollectionView.dataSource = self
        fetchExhibitions()
        pageControl.numberOfPages = currentExhibition.count
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        slideTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        timer.invalidate()
    }
    
    
    func slideTimer() {
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    @objc func timerAction() {
        
        let nextPosition = (currentIndex < currentExhibition.count - 1) ? currentIndex + 1 : 0
        slideCollectionView.scrollToItem(at: IndexPath(item: nextPosition, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentExhibition.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: HomePageCollectionViewCell = slideCollectionView.dequeueReusableCell(withReuseIdentifier: "slideCell", for: indexPath) as! HomePageCollectionViewCell
        let exhibitions = self.currentExhibition[indexPath.item]
        
        if let imageUrl = exhibitions.exhibitionCoverImg {
            ImageService.getImage(urlString: imageUrl) { image in
                cell.slideImageView.image = image
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: slideCollectionView.frame.width, height: slideCollectionView.frame.height)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentIndex = Int(scrollView.contentOffset.x / slideCollectionView.frame.size.width)
        pageControl.currentPage = currentIndex
    }
    
    
    func fetchExhibitions() {
        let ref = database.child("exhibitions")
        ref.observe(.childAdded) { (snapshot) in
            ref.observe(.value) { (DataSnapshot) in
                guard let dictionary = snapshot.value as? [String: String] else { return }
                let exhibition = Exhibition()
                exhibition.exhibitionCoverImg = dictionary["exhibitionCoverImg"]
                exhibition.exhibitionTitle = dictionary["exhibitionTitle"]
                exhibition.exhibitionDate = dictionary["exhibitionStartDate"]! + " - " + dictionary["exhibitionEndDate"]!
                exhibition.exhibitionDate = self.dateFormat(startDate: dictionary["exhibitionStartDate"]!, endDate: dictionary["exhibitionEndDate"]!)
                exhibition.exhibitionGallery = dictionary["exhibitionGallery"]
                exhibition.exhibitionType = self.exhibitonType(startDate: dictionary["exhibitionStartDate"]!, endDate: dictionary["exhibitionEndDate"]!)
                let type = self.exhibitonType(startDate: dictionary["exhibitionStartDate"]!, endDate: dictionary["exhibitionEndDate"]!)
                if type == 1 {
                    self.currentExhibition.append(exhibition)
                    print(self.currentExhibition)
                }
            }
            
            DispatchQueue.main.async {
                self.slideCollectionView.reloadData()
            }
        }
    }
    
    func dateFormat(startDate: String, endDate: String) -> String {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy"
        let startDate = df.date(from: startDate)
        let endDate = df.date(from: endDate)
        df.dateFormat = "MMM d, yyyy"
        let strStart = df.string(from: startDate!)
        let strEnd = df.string(from: endDate!)
        return strStart + " - " + strEnd
    }
    
    func exhibitonType(startDate: String, endDate: String) -> Int {
        let date = Date()
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy"
        let today = df.date(from: df.string(from: date))!
        let start = df.date(from: startDate)!
        let end = df.date(from: endDate)!
        
        if today >= start && today <= end {
            return 1 // "Current exhibition"
        } else {
            return 2
        }
    }
}
