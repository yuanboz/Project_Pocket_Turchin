//
//  HomeViewController.swift
//  Project_PocketTurchin
//
//  Created by 周元博 on 1/6/21.
//

import UIKit
import FirebaseStorage
import Firebase
import FirebaseDatabase

class HomeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet var galleryTable: UITableView!
    
    var adminAddBarButton: UIBarButtonItem!
    
    private let storage = Storage.storage()
    private let datebase = Database.database().reference()
    
    var exhibition = [Exhibition]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        galleryTable.delegate = self
        galleryTable.dataSource = self
        galleryTable.separatorStyle = .none
        self.adminAddBarButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(adminAddBarButtonTapped))
        fetchResource()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkAdminMode()
        
    }
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return exhibition.count
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exhibition.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 215
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: HomeTableViewCell = galleryTable.dequeueReusableCell(withIdentifier: "homeTableViewCell") as! HomeTableViewCell
        
        let exhibitions = exhibition[indexPath.row]

        cell.titleLabel.text = exhibitions.exhibitionTitle
        cell.dateLabel.text = exhibitions.exhibitionDate
        if let url = URL(string: exhibitions.exhibitionCoverImg!) {
            URLSession.shared.dataTask(with: url, completionHandler: {(data, _, err) in
                if err != nil {
                    print(err!)
                    return
                }

                DispatchQueue.main.async {
                    cell.cellImage.image = UIImage(data: data!)
                }
            }).resume()
        }
//        cell.cellImage.image = UIImage(named: "image2.jpg")
        cell.cellImage.layer.cornerRadius = 10;
        cell.cellImage.layer.masksToBounds = true;

        return cell
    }
    
    func checkAdminMode() {
        let adminMode = UserDefaults.standard.bool(forKey: "adminMode")
        
        if adminMode == true {
            showAdminElements()
        } else {
            hideAdminElements()
        }
    }
    
    func showAdminElements() {
        self.navigationItem.rightBarButtonItem = adminAddBarButton
    }
    
    func hideAdminElements() {
        self.navigationItem.rightBarButtonItem = nil
    }
    
    @objc func adminAddBarButtonTapped(_ sender: UIBarButtonItem) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let secondVC = storyBoard.instantiateViewController(withIdentifier: "adminUploadPage") as? AdminUploadViewController else { return }
        
        self.present(secondVC, animated: true, completion: nil)
    }
    
    // Fetch resources from firebase
    func fetchResource() {
        let ref = datebase.child("exhibitions")
        
        ref.observe(.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: String] else { return }
            let exhibition = Exhibition()
            exhibition.exhibitionCoverImg = dictionary["exhibitionCoverImg"]
            exhibition.exhibitionTitle = dictionary["exhibitionTitle"]
            exhibition.exhibitionDate = dictionary["exhibitionDate"]
            self.exhibition.append(exhibition)
            
            DispatchQueue.main.async {
                self.galleryTable.reloadData()
            }
        }
    }

}
