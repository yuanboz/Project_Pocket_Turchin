//
//  DetailPageViewController.swift
//  Project_PocketTurchin
//
//  Created by 周元博 on 1/11/21.
//

import UIKit
import FloatingPanel

class DetailPageViewController: UIViewController, FloatingPanelControllerDelegate {

    @IBOutlet var coverImageView: UIImageView!
    
    var coverImage: UIImage?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        coverImageView.image = coverImage
        let fpc = FloatingPanelController()
        
        guard let contentVC = storyboard?.instantiateViewController(identifier: "fpc_content") as? ContentViewController else { return }
        
        fpc.set(contentViewController: contentVC)
        fpc.layout = myPanelLandscapeLayout()
        fpc.delegate = self
        fpc.addPanel(toParent: self)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notificaiton: NSNotification) {
        if ((notificaiton.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y = 0
            }
        }
    }
    
  
}


class myPanelLandscapeLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .half
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 0.0, edge: .top, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(absoluteInset: 300.0, edge: .bottom, referenceGuide: .safeArea),
//            .tip: FloatingPanelLayoutAnchor(absoluteInset: 44.0, edge: .bottom, referenceGuide: .safeArea),
        ]
    }

}
