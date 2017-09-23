//
//  GTranslateMainParentViewController.swift
//  main
//
//  Created by jeanclad on 2017. 5. 11..
//  Copyright © 2017년 . All rights reserved.
//

import Foundation
import ISHPullUp

class GTranslateMainParentViewController: ISHPullUpViewController, GTranslateMainViewControllerDelegate {

    var contentVC: GTranslateMainViewController?
    var bottomVC: GTranslateBottomVIewController?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if self.navigationController?.viewControllers.last?.isKind(of: GTranslateVisionPhotoViewContoller.classForCoder()) == false {
            self.navigationController?.isNavigationBarHidden = false
        }
    }
    
    private func commonInit() {
        let storyboard: UIStoryboard = UIStoryboard(name: "GTranslate", bundle: nil)
        contentVC = storyboard.instantiateViewController(withIdentifier: "GTranslateMainViewController") as? GTranslateMainViewController
        bottomVC = storyboard.instantiateViewController(withIdentifier: "GTranslateBottomVIewController") as? GTranslateBottomVIewController
        
        contentVC?.delegate = self
        contentViewController = contentVC
        bottomViewController = bottomVC
        bottomVC?.pullUpController = self
        contentDelegate = contentVC
        sizingDelegate = bottomVC
        stateDelegate = bottomVC
    }
    
    // MARK: Public Method
    public func selectedItems(item: GTranslateBottomContentModel) {
        contentVC?.relateBottomItem(item: item)
    }
    
    // MARK: GTranslateMainVeiwControllerDelegate
    func gTranslateMainViewControllerLangChanged() {
        bottomVC?.refreshTipViewControllers()
    }
    
    func gTranslateMainViewControllerAddTempRecentData(recentData: RecentData) {
        bottomVC?.addTempDataRecentViewController(recentData: recentData)
    }
}
