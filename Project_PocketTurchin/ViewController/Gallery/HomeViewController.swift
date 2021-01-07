//
//  HomeViewController.swift
//  Project_PocketTurchin
//
//  Created by 周元博 on 1/6/21.
//

import UIKit
import FirebaseStorage

class HomeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet var galleryTable: UITableView!

    var adminAddBarButton: UIBarButtonItem!
    
    private let storage = Storage.storage()
    var imageArray = [Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        galleryTable.delegate = self
        galleryTable.dataSource = self
        galleryTable.separatorStyle = .none
        self.adminAddBarButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(adminAddBarButtonTapped))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkAdminMode()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return imageArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 215
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: HomeTableViewCell = galleryTable.dequeueReusableCell(withIdentifier: "homeTableViewCell") as! HomeTableViewCell
        cell.cellImage.image = UIImage(named: "image2.jpg")
        cell.cellImage.layer.cornerRadius = 20;
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
        guard let secondVC = storyBoard.instantiateViewController(withIdentifier: "adminUploadPage") as? AdminUploadViewController else {  return }
        self.present(secondVC, animated: true, completion: nil)
    }
    

}
