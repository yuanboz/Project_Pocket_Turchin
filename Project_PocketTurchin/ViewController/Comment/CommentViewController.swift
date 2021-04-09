//
//  CommentViewController.swift
//  Project_PocketTurchin
//
//  Created by 周元博 on 4/8/21.
//

import UIKit
import Firebase

class CommentViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet var commentTableView: UITableView!
    
    private let db = Firestore.firestore()
    
    var gallery = [String]()
    let cellID = "cellID"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentTableView.delegate = self
        commentTableView.dataSource = self
        setUpNavigationImage()
        fetchExhibition()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gallery.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(identifier: "CommentDetailVC") as! CommentDetailVC
        vc.exhibition = self.gallery[indexPath.row]
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = commentTableView.dequeueReusableCell(withIdentifier: cellID)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellID)
        }
        let exhibition = self.gallery[indexPath.row]
        cell?.textLabel?.text = exhibition.capitalized
        return cell!
    }
    
    
    func setUpNavigationImage() {
        let logo = UIImage(named: "navigationBGImage.png")
        let imageView = UIImageView(image: logo)
        self.navigationItem.titleView = imageView
    }
    
    func fetchExhibition() {
        db.collection("comments").getDocuments { (snapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for doc in snapshot!.documents {
                    self.gallery.append(doc.documentID as String)
                }
            }
            
            DispatchQueue.main.async {
                self.commentTableView.reloadData()
            }
        }
    }
}
