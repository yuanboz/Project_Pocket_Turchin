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
    var exhibition = [String]()
    var date = [String]()
    var exhibitionTitle = [String]()
    var exhibitionImg = [String]()
    var exhibitionDate = [String]()
    let cellID = "cellID"
    
    
    var exhibitions = [[Exhibition]]()
    var currentExhibition = [Exhibition]()  // Store current exhibitions
    var upcomingExhibition = [Exhibition]() // Store upcoming exhibitions
    var pastExhibition = [Exhibition]()     // Store past exhibitions
    var updateExhibition = [[Exhibition]]()  // update table when user search for specific exhibiton
    
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
        return exhibition.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 215
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GalleryExhibitionTableViewCell = galleryExhibitionTableView.dequeueReusableCell(withIdentifier: "galleryExhibitionTableViewCell") as! GalleryExhibitionTableViewCell
//        cell.exhibitionName.text = exhibitionTitle[indexPath.row]
//        cell.exhibitionDate.text = exhibitionDate[indexPath.row]
//        let imageUrl = exhibitionImg[indexPath.row]
//        ImageService.getImage(urlString: imageUrl) { image in
//            cell.galleryExhibitionImageVIew.image = image
//        }
        
        return cell
    }
    
    func fetchExhibitions() {
        db.collection("gallery").document(galleryName.lowercased()).getDocument { (doc, err) in
            guard let doc = doc, err == nil else { return }
            let docDate = doc.data()! as NSDictionary
            for (key,value) in docDate {
                self.exhibition.append(key as! String)
                self.date.append(value as! String)
                let ref = self.database.child("exhibitions").child(key as! String)
                ref.observe(.childAdded, with: { (snapshot) in
                    print(value)
//                    let title = value?["exhibitionTitle"] as! String
//                    let url = value?["exhibitionCoverImg"] as! String
//                    let startDate = value?["exhibitionStartDate"] as! String
//                    let endDate = value?["exhibitionEndDate"] as! String
//                    let date = dateHelper.dateFormat(startDate: startDate, endDate: endDate)
//                    self.exhibitionTitle.append(title)
//                    self.exhibitionImg.append(url)
//                    self.exhibitionDate.append(date)
//                    print(self.exhibitionTitle)
                })
                
                DispatchQueue.main.async {
                    self.galleryExhibitionTableView.reloadData()
                }
            }
        }
    }
    
    
}

