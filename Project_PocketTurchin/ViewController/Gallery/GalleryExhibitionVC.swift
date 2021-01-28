////  GalleryExhibitionVC.swift
//  Project_PocketTurchin
//
//  Created by 周元博 on 1/27/21.
//

import UIKit
import Firebase

class GalleryExhibitionVC: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet var galleryExhibitionTableView: UITableView!
    
    var gallery = [String]()
    var galleryName: String = ""
    var index: Int = 0
    var exhibition = [String]()
    var date = [String]()
    let cellID = "cellID"
    
    private let db = Firestore.firestore()

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
        return 150
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GalleryExhibitionTableViewCell = galleryExhibitionTableView.dequeueReusableCell(withIdentifier: "galleryExhibitionTableViewCell") as! GalleryExhibitionTableViewCell
        cell.exhibitionName.text = exhibition[indexPath.row]
        cell.exhibitionDate.text = date[indexPath.row]
        
        return cell
    }
    
    func fetchExhibitions() {
        db.collection("gallery").document(galleryName.lowercased()).getDocument { (doc, err) in
            guard let doc = doc, err == nil else { return }
            let docDate = doc.data()! as NSDictionary
            for (key,value) in docDate {
                self.exhibition.append(key as! String)
                self.date.append(value as! String)
            }
            DispatchQueue.main.async {
                self.galleryExhibitionTableView.reloadData()
            }
            //print(self.exhibition,self.date)
        }
    }

}
