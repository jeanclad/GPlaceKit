//
//  GTranslateCoachMarkPageViewController.swift
//  main
//
//  Created by jeanclad on 2017. 6. 15..
//  Copyright © 2017년 interpark-int. All rights reserved.
//

import Foundation

class GTranslateCoachMarkPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

//        let totalViewCount = 3
    let totalViewCount = 1
    var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.dataSource = self
        
        let firstViewController = getViewControllerAtIndex(index: 0) as GTranslateCoachMarkPageContentViewController
        setViewControllers([firstViewController] as [UIViewController], direction: .forward, animated: false, completion: nil)
        
        pageControl = UIPageControl(frame:
            CGRect(x: 0,
                   y: (UIScreen.main.bounds.height / 2) + (firstViewController.guardView.frame.size.height / 2) - 30,
                   width: UIScreen.main.bounds.width,
                   height: 37))

        pageControl.numberOfPages = 3
        pageControl.currentPage = 0
        pageControl.isUserInteractionEnabled = false
        
//        view.addSubview(pageControl)
    }
    
    // MARK: Private
    private func getViewControllerAtIndex(index: NSInteger) -> GTranslateCoachMarkPageContentViewController {
        
        let storyboard: UIStoryboard = UIStoryboard(name: "GTranslate", bundle: nil)
        let pageContentViewController = storyboard.instantiateViewController(withIdentifier: "GTranslateCoachMarkPageContentViewController") as? GTranslateCoachMarkPageContentViewController
        
        if index == 0 {
            //            pageContentViewController?.pageIndex = 0
            //            pageContentViewController?.coachImageName = "coach_1.png"
            pageContentViewController?.pageIndex = 0
            pageContentViewController?.coachImageName = "coach_2.png"
            
        }
        //        else if index == 1 {
        //            pageContentViewController?.pageIndex = 1
        //            pageContentViewController?.coachImageName = "coach_2.png"
        //        } else {
        //            pageContentViewController?.pageIndex = 2
        //            pageContentViewController?.coachImageName = "coach_3.png"
        //        }
        
        return pageContentViewController!
    }
    
    // MARK: Public
    public func showViewController(index: NSInteger) {
        let firstViewController = getViewControllerAtIndex(index: index) as GTranslateCoachMarkPageContentViewController
        setViewControllers([firstViewController] as [UIViewController], direction: .forward, animated: false, completion: nil)
    }
    
    
    // MARK: UIPageViewControllerDelegate
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let pageContent: GTranslateCoachMarkPageContentViewController = viewController as! GTranslateCoachMarkPageContentViewController
        
        var index = pageContent.pageIndex
        if index == 0 || index == NSNotFound {
            return nil
        }
        
        index = index! - 1
        
        return getViewControllerAtIndex(index: index!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let pageContent: GTranslateCoachMarkPageContentViewController = viewController as! GTranslateCoachMarkPageContentViewController
        
        var index = pageContent.pageIndex
        if index == NSNotFound {
            return nil
        }
        index = index! + 1
        
        if index! > totalViewCount - 1 {
            return nil;
        }
        
        return getViewControllerAtIndex(index: index!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let itemController = pendingViewControllers[0] as? GTranslateCoachMarkPageContentViewController {
            pageControl.currentPage = itemController.pageIndex!
        }
    }
    
    //    func presentationCount(for pageViewController: UIPageViewController) -> Int {
    //        return totalViewCount
    //    }
    //
    //    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
    //        return 0
    //    }
}
