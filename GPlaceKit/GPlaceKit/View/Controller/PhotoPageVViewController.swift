//
//  PhotoPageVViewController.swift
//  GPlaceKit
//
//  Created by jeanclad on 2017. 9. 23..
//  Copyright © 2017년 jeanclad. All rights reserved.
//

import UIKit

class PhotoPageVViewController: UIPageViewController {

    var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let firstViewController = getViewControllerAtIndex(index: 0) as PhotoViewController
        setViewControllers([firstViewController] as [UIViewController], direction: .forward, animated: true)
        closeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        closeButton.setTitle("닫기", for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        view.addSubview(closeButton)
    }

    // MARK: Action
    func closeButtonPressed(sender: UIButton) {
        dismiss(animated: true)
    }
    
    // MARK: Private
    private func getViewControllerAtIndex(index: NSInteger) -> PhotoViewController {
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let photoViewController = storyboard.instantiateViewController(withIdentifier: "PhotoViewController") as? PhotoViewController
        
        if index == 0 {
//            photoViewController?.pageIndex = 0
//            photoViewController?.coachImageName = "coach_2.png"
            
        }
        //        else if index == 1 {
        //            pageContentViewController?.pageIndex = 1
        //            pageContentViewController?.coachImageName = "coach_2.png"
        //        } else {
        //            pageContentViewController?.pageIndex = 2
        //            pageContentViewController?.coachImageName = "coach_3.png"
        //        }
        
        return photoViewController!
    }
}
