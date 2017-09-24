//
//  PhotoPageVViewController.swift
//  GPlaceKit
//
//  Created by jeanclad on 2017. 9. 23..
//  Copyright © 2017년 jeanclad. All rights reserved.
//

import UIKit

class PhotoPageVViewController: UIPageViewController {

    private var closeButton: UIButton!
    internal var photoPageViewModel = PhotoPageViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let firstViewController = getViewControllerAtIndex(index: 0) as PhotoViewController
        setViewControllers([firstViewController] as [UIViewController], direction: .forward, animated: true)
        closeButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 50 - 20, y: 20, width: 500, height: 50))
        closeButton.setTitle("닫기", for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        closeButton.sizeToFit()
        view.addSubview(closeButton)
    }

    // MARK: Action
    func closeButtonPressed(sender: UIButton) {
        dismiss(animated: true)
    }
    
    // MARK: Private
    private func getViewControllerAtIndex(index: NSInteger) -> PhotoViewController {
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let photoViewController = storyboard.instantiateViewController(withIdentifier: "PhotoViewController") as! PhotoViewController
        
        let imageUrl = photoPageViewModel.getPhotoUrl(size: CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height), index: index)
        if let imageUrl = imageUrl {
            let photoModel = PhotoModel(imageUrl: imageUrl)
            let photoViewModel = PhotoViewModel()
            photoViewModel.photoModel = photoModel
            photoViewController.photoViewModel = photoViewModel
        }
        
//        if index == 0 {
//            photoViewController?.pageIndex = 0
//            photoViewController?.coachImageName = "coach_2.png"
            
//        }
        //        else if index == 1 {
        //            pageContentViewController?.pageIndex = 1
        //            pageContentViewController?.coachImageName = "coach_2.png"
        //        } else {
        //            pageContentViewController?.pageIndex = 2
        //            pageContentViewController?.coachImageName = "coach_3.png"
        //        }
        
        return photoViewController
    }
}
