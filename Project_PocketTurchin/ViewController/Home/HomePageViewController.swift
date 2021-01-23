//
//  HomePageViewController.swift
//  Project_PocketTurchin
//
//  Created by 周元博 on 1/22/21.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase

class HomePageViewController: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource {

    @IBOutlet var sliderCollectionView: UICollectionView!
    @IBOutlet var sliderPageController: UIPageControl!
    
    private let storage = Storage.storage()
    private let datebase = Database.database().reference()
    
    var homeSliderImage = [Exhibition]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sliderCollectionView.delegate = self
        sliderCollectionView.dataSource = self
        fetchResource()
        print("1")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return homeSliderImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: HomePageCollectionViewCell = sliderCollectionView.dequeueReusableCell(withReuseIdentifier: "sliderCollectionCell", for: indexPath) as! HomePageCollectionViewCell
        let exhibitions = homeSliderImage[indexPath.row]
        
        if let imageUrl = exhibitions.exhibitionCoverImg {
            ImageService.getImage(urlString: imageUrl) { image in
                cell.sliderImageView.image = image
            }
        }
        
        return cell
    }
    
    
    // Fetch resources from firebase
    func fetchResource() {
        let ref = datebase.child("exhibitions")
        
        ref.observe(.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: String] else { return }
            let exhibition = Exhibition()
            print(dictionary.values)
            exhibition.exhibitionCoverImg = dictionary["exhibitionCoverImg"]
            exhibition.exhibitionTitle = dictionary["exhibitionTitle"]
            exhibition.exhibitionDate = dictionary["exhibitionDate"]
            self.homeSliderImage.append(exhibition)

            DispatchQueue.main.async {
                self.sliderCollectionView.reloadData()
            }
        }
    }

}

extension HomePageViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = sliderCollectionView.frame.size
        return CGSize(width: size.width, height: size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}
