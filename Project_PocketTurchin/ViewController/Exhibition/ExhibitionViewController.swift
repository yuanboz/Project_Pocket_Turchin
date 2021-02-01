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

class ExhibitionViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating {
   
    @IBOutlet var galleryTable: UITableView!
    
    var adminAddBarButton: UIBarButtonItem!
    var searchButton: UIBarButtonItem!
    var searchController: UISearchController!
    
    private let storage = Storage.storage()
    private let database = Database.database().reference()
    
    var exhibition = [[Exhibition]]()
    var currentExhibition = [Exhibition]()  // Store current exhibitions
    var upcomingExhibition = [Exhibition]() // Store upcoming exhibitions
    var pastExhibition = [Exhibition]()     // Store past exhibitions
    var updateExhibition = [[Exhibition]]()  // update table when user search for specific exhibiton
    
    var count: Int = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        galleryTable.delegate = self
        galleryTable.dataSource = self
        galleryTable.separatorStyle = .none
        setUpAdminButton()
        setUpSearchBar()
        fetchExhibitions()
        setUpNavigationImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkAdminMode()
        //fetchExhibitions()
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
//        if let searchText = searchController.searchBar.text {
//            filterCurrentDataSource(searchTerm: searchText)
//        }
    }

//    func filterCurrentDataSource(searchTerm: String) {
//        guard !searchTerm.isEmpty else {
//            currentExhibition = exhibition
//            galleryTable.reloadData()
//            return
//        }
//        currentExhibition = exhibition.filter { (exhibition) -> Bool in
//            (exhibition.exhibitionTitle?.lowercased().contains(searchTerm.lowercased()))!
//        }
//        galleryTable.reloadData()
//    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return updateExhibition.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: CGRect(x: 0, y: 10, width: view.frame.size.width, height: 30))
        if !updateExhibition[section].isEmpty {
            let type: Int = updateExhibition[section][0].exhibitionType!
            if type == 0 {
                label.text = "Past Exhibitions"
            } else if type == 1 {
                label.text = "Current Exhibitions"
            } else if type == 2 {
                label.text = "Upcoming Exhibiitons"
            }
            
        }
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.darkGray
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return updateExhibition[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 215
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell: ExhibitionTableViewCell = galleryTable.dequeueReusableCell(withIdentifier: "exhibitionTableViewCell") as! ExhibitionTableViewCell
        
        let exhibitions = self.updateExhibition[indexPath.section][indexPath.row]
    
        cell.titleLabel.text = exhibitions.exhibitionTitle
        cell.dateLabel.text = exhibitions.exhibitionDate
        cell.galleryLabel.text = exhibitions.exhibitionGallery
        
        if let imageUrl = exhibitions.exhibitionCoverImg {
            ImageService.getImage(urlString: imageUrl) { image in
                cell.cellImage.image = image
            }
        }
        cell.cellImage.layer.cornerRadius = 20
        cell.cellImage.layer.masksToBounds = true
        cell.upperView.layer.cornerRadius = 20
        cell.upperView.layer.masksToBounds = true

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(identifier: "DetailPageViewController") as! DetailPageViewController
        let exhibitions = updateExhibition[indexPath.section][indexPath.row]
        let defaults = UserDefaults.standard
        
        if let imageUrl = exhibitions.exhibitionCoverImg {
            ImageService.getImage(urlString: imageUrl) { image in
                vc.coverImage = image
            }
        }
        defaults.set(exhibitions.exhibitionTitle, forKey: "exhibitionTitle")
        defaults.set(exhibitions.exhibitionDate, forKey: "exhibitionDate")
        
        self.navigationController?.pushViewController(vc, animated: true)
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
                if type == 0 {
                    self.pastExhibition.append(exhibition)
                } else if type == 1 {
                    self.currentExhibition.append(exhibition)
                } else if type == 2{
                    self.upcomingExhibition.append(exhibition)
                }
                let total = self.pastExhibition.count + self.currentExhibition.count + self.upcomingExhibition.count
                if total == DataSnapshot.childrenCount {
                    if self.exhibition.count == 3 {
                        self.exhibition.removeAll()
                        self.exhibition.append(self.currentExhibition)
                        self.exhibition.append(self.upcomingExhibition)
                        self.exhibition.append(self.pastExhibition)
                    } else {
                        self.exhibition.append(self.currentExhibition)
                        self.exhibition.append(self.upcomingExhibition)
                        self.exhibition.append(self.pastExhibition)
                    }
                    self.updateExhibition = self.exhibition
                }
                
                DispatchQueue.main.async {
                    self.galleryTable.reloadData()
                }
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
        } else if today < start {
            return 2 //"Upcomming exhibition"
        } else {
            return 0 //"Past exhibition"
        }
    }

}
