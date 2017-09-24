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
    fileprivate var pageControl: UIPageControl!
    
    internal var photoPageViewModel = PhotoPageViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.dataSource = self

        let firstViewController = getViewControllerAtIndex(index: 0) as PhotoViewController
        setViewControllers([firstViewController] as [UIViewController], direction: .forward, animated: true)
        
        closeButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 50 - 20, y: 20, width: 500, height: 50))
        closeButton.setTitle("닫기", for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        closeButton.sizeToFit()
        view.addSubview(closeButton)
        
        pageControl = UIPageControl(frame:
            CGRect(x: 0,
                   y: (UIScreen.main.bounds.height / 2) + (firstViewController.view.frame.size.height / 2) - 60,
                   width: UIScreen.main.bounds.width,
                   height: 37))
        
        pageControl.numberOfPages = photoPageViewModel.numberOfItem
        pageControl.currentPage = 0
        pageControl.isUserInteractionEnabled = false
        view.addSubview(pageControl)

    }

    // MARK: Action
    func closeButtonPressed(sender: UIButton) {
        dismiss(animated: true)
    }
    
    // MARK: Private
    fileprivate func getViewControllerAtIndex(index: NSInteger) -> PhotoViewController {
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let photoViewController = storyboard.instantiateViewController(withIdentifier: "PhotoViewController") as! PhotoViewController
        
        let imageUrl = photoPageViewModel.getPhotoUrl(size: CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height), index: index)
        if let imageUrl = imageUrl {
            let photoModel = PhotoModel(imageUrl: imageUrl)
            photoModel.pageIndex = index
            
            let photoViewModel = PhotoViewModel()
            photoViewModel.photoModel = photoModel
            photoViewController.photoViewModel = photoViewModel
        }
        
        return photoViewController
    }
}

extension PhotoPageVViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let pageContent = viewController as! PhotoViewController
        
        var index = pageContent.photoViewModel.photoModel?.pageIndex ?? NSNotFound
        if index == 0 || index == NSNotFound {
            return nil
        }
        
        index = index - 1
        
        return getViewControllerAtIndex(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let pageContent = viewController as! PhotoViewController
        
        var index = pageContent.photoViewModel.photoModel?.pageIndex ?? NSNotFound
        if index == NSNotFound {
            return nil
        }
        index = index + 1
        
        if index > photoPageViewModel.numberOfItem - 1 {
            return nil;
        }
        
        return getViewControllerAtIndex(index: index)
    }
}

extension PhotoPageVViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let itemController = pendingViewControllers[0] as? PhotoViewController {
            if let model = itemController.photoViewModel.photoModel {
                pageControl.currentPage = model.pageIndex
            } else {
                pageControl.currentPage = 0
            }
        }
    }
}
