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

class HomeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating {
   
    @IBOutlet var galleryTable: UITableView!
    
    var adminAddBarButton: UIBarButtonItem!
    var searchButton: UIBarButtonItem!
    var searchController: UISearchController!
    
    private let storage = Storage.storage()
    private let datebase = Database.database().reference()
    
    var exhibition = [Exhibition]()
    var currentExhibition = [Exhibition]() // update table
    
    override func viewDidLoad() {
        super.viewDidLoad()
        galleryTable.delegate = self
        galleryTable.dataSource = self
        galleryTable.separatorStyle = .none
        setUpAdminButton()
        setUpSearchBar()
        fetchResource()
        setUpNavigationImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkAdminMode()
    }
    
    func setUpAdminButton() {
        self.adminAddBarButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(adminAddBarButtonTapped))
    }
    
    func setUpNavigationImage() {
        let logo = UIImage(named: "navigationBGImage.png")
        let imageView = UIImageView(image: logo)
        self.navigationItem.titleView = imageView
    }
    
    func setUpSearchBar() {
        self.searchButton = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(searchButtonTapped))
        self.navigationItem.leftBarButtonItem = searchButton
        searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.showsCancelButton = true
    }
    
    @objc func searchButtonTapped() {
        present(searchController, animated: true, completion: nil)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterCurrentDataSource(searchTerm: searchText)
        }
    }

    func filterCurrentDataSource(searchTerm: String) {
        guard !searchTerm.isEmpty else {
            currentExhibition = exhibition
            galleryTable.reloadData()
            return
        }
        currentExhibition = exhibition.filter { (exhibition) -> Bool in
            (exhibition.exhibitionTitle?.lowercased().contains(searchTerm.lowercased()))!
        }
        galleryTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentExhibition.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 215
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: HomeTableViewCell = galleryTable.dequeueReusableCell(withIdentifier: "homeTableViewCell") as! HomeTableViewCell
        let exhibitions = currentExhibition[indexPath.row]

        cell.cellImage.layer.cornerRadius = 20
        cell.cellImage.layer.masksToBounds = true
        cell.upperView.layer.cornerRadius = 20
        cell.upperView.layer.masksToBounds = true
    
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
            self.currentExhibition = self.exhibition
            
            DispatchQueue.main.async {
                self.galleryTable.reloadData()
            }
        }
    }

}
