//
//  AdminEditViewController.swift
//  Project_PocketTurchin
//
//  Created by 周元博 on 2/17/21.
//

import UIKit
import FirebaseDatabase

class AdminEditViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet var adminTableView: UITableView!
    
    let cellID = "cellID"
    var exhibitionList = [String]()
    
    private let database = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adminTableView.delegate = self
        adminTableView.dataSource = self
        fetchFromDB()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exhibitionList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AdminEditTableViewCell = adminTableView.dequeueReusableCell(withIdentifier: "cellID") as! AdminEditTableViewCell
        cell.adminLabel.text = exhibitionList[indexPath.row]
        
        return cell
    }
    
    
    func fetchFromDB() {
        let ref = database.child("exhibitions")
        ref.observe(.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? [String:String] else { return }
            let buffer: String
            buffer = dictionary["exhibitionTitle"]!
            print(buffer)
            self.exhibitionList.append(buffer)
            
            DispatchQueue.main.async {
                self.adminTableView.reloadData()
            }
        }
    }
    
    


}
