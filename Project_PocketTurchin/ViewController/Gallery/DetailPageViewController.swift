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
    var exhibitionTitle: String?
    var exhibitionDate: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coverImageView.image = coverImage
        let fpc = FloatingPanelController()
        
        guard let contentVC = storyboard?.instantiateViewController(identifier: "fpc_content") as? ContentViewController else { return }
        
        fpc.set(contentViewController: contentVC)
        fpc.layout = myPanelLandscapeLayout()
        fpc.delegate = self
        fpc.addPanel(toParent: self)
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
