//
//  GalleryViewController.swift
//  Project_PocketTurchin
//
//  Created by 周元博 on 1/24/21.
//

import UIKit
import FirebaseDatabase
import Firebase

class GalleryViewController: UIViewController, UITableViewDataSource,UITableViewDelegate {

    @IBOutlet var galleryTableView: UITableView!
    
    private let db = Firestore.firestore()
    
    var gallery = [String]()
    let cellID = "cellID"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        galleryTableView.delegate = self
        galleryTableView.dataSource = self
        fetchGallery()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gallery.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = galleryTableView.dequeueReusableCell(withIdentifier: cellID)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellID)
        }
        cell?.textLabel?.text = self.gallery[indexPath.row]
        return cell!
    }
    
    
    
    func fetchGallery() {
        db.collection("gallery").getDocuments { (snapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for doc in snapshot!.documents {
                    self.gallery.append(doc.documentID as String)
                }
            }
            
            DispatchQueue.main.async {
                self.galleryTableView.reloadData()
            }
        }
    }
            

}
