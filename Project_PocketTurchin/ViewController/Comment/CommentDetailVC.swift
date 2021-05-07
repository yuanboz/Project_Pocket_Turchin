//
//  CommentDetailVC.swift
//  Project_PocketTurchin
//
//  Created by 周元博 on 4/8/21.
//

import UIKit
import Firebase

class CommentDetailVC: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet var commentDetailTableView: UITableView!
    
    private let db = Firestore.firestore()
    
    let cellID = "cellID"
    var exhibition: String = ""
    var user = [String]()
    var full_comment = [[String]]()
    var commentArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentDetailTableView.dataSource = self
        commentDetailTableView.delegate = self
        fetchComment()
    }
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return user.count
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 20
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let label = UILabel(frame: CGRect(x: 0, y: 10, width: view.frame.size.width, height: 30))
//
//        label.text = user[section]
//
//        label.textAlignment = .center
//        label.textColor = UIColor.white
//        label.backgroundColor = UIColor.darkGray
//        return label
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return commentArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = commentDetailTableView.dequeueReusableCell(withIdentifier: cellID)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellID)
        }
        cell?.textLabel?.text = self.commentArray[indexPath.row]
        
        return cell!
    }

    
    func fetchComment() {
        db.collection("comments").document(exhibition).getDocument { (document, err) in
            if err == nil {
                if document != nil && document!.exists {
                    guard let data = document!.data() else { return }
                    for name in data.keys {
                        self.user.append(name)
                        self.full_comment.append(data[name] as! [String])
                    }
                    //print(self.user)
                    //print(self.full_comment)
                    for n in 0..<self.user.count {
                        for comment in self.full_comment[n] {
                            let com = "@\(self.user[n]): " + comment
                            self.commentArray.append(com)
                        }
                    }
                    //print(self.commentArray)
                    //print(self.commentArray.count)
                    
                    DispatchQueue.main.async {
                        self.commentDetailTableView.reloadData()
                    }
                    
                }
            }
        }
    }
    


}
