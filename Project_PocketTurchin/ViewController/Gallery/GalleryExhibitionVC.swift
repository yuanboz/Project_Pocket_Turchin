////  GalleryExhibitionVC.swift
//  Project_PocketTurchin
//
//  Created by 周元博 on 1/27/21.
//

import UIKit
import Firebase
import FirebaseDatabase

class GalleryExhibitionVC: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet var galleryExhibitionTableView: UITableView!

    var gallery = [String]()
    var galleryName: String = ""
    var index: Int = 0
    let cellID = "cellID"
    
    var exhibitions = [Exhibition]()
    
    private let db = Firestore.firestore()
    
    private let database = Database.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        galleryExhibitionTableView.delegate = self
        galleryExhibitionTableView.dataSource = self
        galleryName = gallery[index].capitalized
        self.navigationItem.title = galleryName
        fetchExhibitions()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exhibitions.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 215
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GalleryExhibitionTableViewCell = galleryExhibitionTableView.dequeueReusableCell(withIdentifier: "galleryExhibitionTableViewCell") as! GalleryExhibitionTableViewCell
        let exhibition = self.exhibitions[indexPath.row]
        cell.exhibitionName.text = exhibition.exhibitionTitle
        cell.exhibitionDate.text = exhibition.exhibitionDate
        if let imageUrl = exhibition.exhibitionCoverImg {
            ImageService.getImage(urlString: imageUrl) { (image) in
                cell.galleryExhibitionImageVIew.image = image
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(identifier: "DetailPageViewController") as! DetailPageViewController
        let defaults = UserDefaults.standard
        if let imageUrl = exhibitions[indexPath.row].exhibitionCoverImg {
            ImageService.getImage(urlString: imageUrl) { (image) in
                vc.coverImage = image
            }
        }
        defaults.set(exhibitions[indexPath.row].exhibitionTitle, forKey: "exhibitionTitle")
        defaults.set(exhibitions[indexPath.row].exhibitionDate, forKey: "exhibitionDate")
        defaults.set(exhibitions[indexPath.row].exhibitionAuthor, forKey: "exhibitionAuthor")
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func fetchExhibitions() {
        let ref = self.database.child("exhibitions")
        ref.observe(.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: String] else { return }
            let exhibition = Exhibition()
            exhibition.exhibitionCoverImg = dictionary["exhibitionCoverImg"]
            exhibition.exhibitionTitle = dictionary["exhibitionTitle"]
            exhibition.exhibitionAuthor = dictionary["exhibitionAuthor"]
            exhibition.exhibitionDate = dictionary["exhibitionStartDate"]! + " - " + dictionary["exhibitionEndDate"]!
            exhibition.exhibitionDate = dateHelper.dateFormat(startDate: dictionary["exhibitionStartDate"]!, endDate: dictionary["exhibitionEndDate"]!)
            exhibition.exhibitionGallery = dictionary["exhibitionGallery"]
            exhibition.exhibitionType = dateHelper.exhibitonType(startDate: dictionary["exhibitionStartDate"]!, endDate: dictionary["exhibitionEndDate"]!)
            //let type = dateHelper.exhibitonType(startDate: dictionary["exhibitionStartDate"]!, endDate: dictionary["exhibitionEndDate"]!)
            let thisGallery = self.galleryName.lowercased()
            if exhibition.exhibitionGallery?.lowercased() == thisGallery {
                self.exhibitions.append(exhibition)
            }
            DispatchQueue.main.async {
                self.galleryExhibitionTableView.reloadData()
            }
        }
    }
    
}

