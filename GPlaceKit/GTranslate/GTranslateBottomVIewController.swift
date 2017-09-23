//
//  GTranslateBottomVIewController.swift
//  main
//
//  Created by jeanclad on 2017. 5. 11..
//  Copyright © 2017년 interpark-int. All rights reserved.
//

import Foundation
import ISHPullUp

class GTranslateBottomVIewController: UIViewController, ISHPullUpSizingDelegate, ISHPullUpStateDelegate, GTranslateBottomTipViewControllerDelegate , GTranslateBottomRecentViewControllerDelegate{
    @IBOutlet var topView: UIView!
    
    @IBOutlet var tipView: UIView!
    @IBOutlet var recentView: UIView!
    @IBOutlet var tipButton: UIButton!
    @IBOutlet var recentButton: UIButton!
    @IBOutlet var tipDotButton: UIImageView!
    @IBOutlet var recentDotButton: UIImageView!
    
    var pullUpController: GTranslateMainParentViewController!
    var tipViewController: GTranslateBottomTipViewController!
    var recentViewController: GTranslateBottomRecentViewController!
    
    private var screenSize: CGSize?
    // we allow the pullUp to snap to the half way point
    private var minHeight = GTranslateConstants.BottomViewHeight.mid
    private var oldPullState: ISHPullUpState?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - 70)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        screenSize = UIScreen.main.bounds.size
        
        pullUpController.topMargin = 0
        pullUpController.snapThreshold = 0.5
        pullUpController.dimmingColor = nil
        
        let rectShape = CAShapeLayer()
        rectShape.bounds = view.frame
        rectShape.position = view.center
        rectShape.path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: [.topRight , .topLeft], cornerRadii: CGSize(width: 9, height: 9)).cgPath
        
        self.view.layer.backgroundColor = UIColor.green.cgColor
        self.view.layer.mask = rectShape
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        topView.addGestureRecognizer(tapGesture)
        
        tipViewController = self.childViewControllers.first as! GTranslateBottomTipViewController
        tipViewController.delegate = self
        
        recentViewController = self.childViewControllers.last as! GTranslateBottomRecentViewController
        recentViewController.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if presentedViewController == nil ||
            presentedViewController?.isKind(of: UIImagePickerController.classForCoder()) == false {
            NotificationCenter.default.addObserver(self, selector: #selector(self.moveBottomView), name: Notification.Name(GTranslateConstants.INotification().getBottomViewMoveNotificationId()), object: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if presentedViewController?.isKind(of: UIImagePickerController.classForCoder()) == false {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    
    // MARK: action
    @IBAction func moveButtonPressed(_ sender: Any) {
        pullUpController.toggleState(animated: true)
    }
    
    @IBAction func categoryButtonPressed(_ sender: Any) {
        let button = sender as! UIButton
        
        if button.tag == 1 {
            tipButton.setTitleColor(ManagerColor().colorFromRGB(0x3c4247), for: .normal)
            recentButton.setTitleColor(ManagerColor().colorFromRGB(0x7e8da0), for: .normal)
            tipDotButton.isHidden = false
            recentDotButton.isHidden = true
            
            showBottomCategory(category: GTranslateConstants.SelectBottomCategory.tip)
        } else {
            tipButton.setTitleColor(ManagerColor().colorFromRGB(0x7e8da0), for: .normal)
            recentButton.setTitleColor(ManagerColor().colorFromRGB(0x3c4247), for: .normal)
            tipDotButton.isHidden = true
            recentDotButton.isHidden = false
            
            showBottomCategory(category: GTranslateConstants.SelectBottomCategory.recent)
        }
    }
    
    
    // MARK: Private Method
    private func showBottomCategory(category: GTranslateConstants.SelectBottomCategory) {
        if category == GTranslateConstants.SelectBottomCategory.recent {
            UIView.animate(withDuration: 0.3, animations: { 
                self.tipView.alpha = 0
                self.recentView.alpha = 1
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.tipView.alpha = 1
                self.recentView.alpha = 0
            })
            
        }
    }
    
    private func getBottomCategory() -> GTranslateConstants.SelectBottomCategory {
        if tipView.alpha == 0 {
            return GTranslateConstants.SelectBottomCategory.recent
        } else {
            return GTranslateConstants.SelectBottomCategory.tip
        }
    }
    
    private func changeBottomViewHeight(height: CGFloat) {
        pullUpController.setBottomHeight(height, animated: true)
        pullUpController.invalidateLayout()
    }
    
    // MARK: Public
    public func refreshTipViewControllers() {
        tipViewController.refreshTableViewControler()
    }
    
    public func addTempDataRecentViewController(recentData: RecentData?) {
        recentViewController.refreshTableViewControler(recentData: recentData!)
    }
    
    
    // MARK: Selectors
    private dynamic func handleTapGesture(gesture: UITapGestureRecognizer) {
        //        if pullUpController.isLocked {
        //            return
        //        }
        
        pullUpController.toggleState(animated: true)
    }
    
    func moveBottomView(_ notification: NSNotification) {
        if let state = notification.userInfo?["state"] as? GTranslateConstants.BottomViewState {
            // do something with your image
            log.info("move bottomView state = \(state)")
            
            if pullUpController.state != .collapsed && pullUpController.state != .dragging{
                if state == GTranslateConstants.BottomViewState.mid {
                    minHeight = GTranslateConstants.BottomViewHeight.mid
                }
                
            } else {
                if state == GTranslateConstants.BottomViewState.down {
                    minHeight = GTranslateConstants.BottomViewHeight.min
                } else if state == GTranslateConstants.BottomViewState.mid {
                    minHeight = GTranslateConstants.BottomViewHeight.mid
                }
            }
            
            changeBottomViewHeight(height: minHeight.rawValue)
        }
    }
    
    
    // MARK: GTranslateBottomTipViewControllerDelegate
    func gTranslateBottomTipViewControllerSelectedItem(item: GTranslateBottomContentModel) {
        pullUpController.selectedItems(item: item)
    }
    
    
    // MARK: GTranslateBottomRecentViewControllerDelegate
    func gTranslateBottomRecentViewControllerSelectedItem(item: GTranslateBottomContentModel) {
        pullUpController.selectedItems(item: item)        
    }
    
    
    // MARK: ISHPullUpSizingDelegate
    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, maximumHeightForBottomViewController bottomVC: UIViewController, maximumAvailableHeight: CGFloat) -> CGFloat {
        //        let totalHeight = view.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        let totalHeight = screenSize!.height - 70
        
        // we allow the pullUp to snap to the half way point
        // we "calculate" the cached value here
        // and perform the snapping in ..targetHeightForBottomViewController..
        //        halfWayPoint = totalHeight / 2.0
        return totalHeight
    }
    
    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, minimumHeightForBottomViewController bottomVC: UIViewController) -> CGFloat {
        //        return topView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        return minHeight.rawValue
    }
    
    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, targetHeightForBottomViewController bottomVC: UIViewController, fromCurrentHeight height: CGFloat) -> CGFloat {
        
        log.info(pullUpViewController.state.rawValue)
        
        // if around 30pt of the half way point -> snap to it
        //        if abs(height - halfWayPoint) < 30 {
        //            return halfWayPoint
        //        }
        //
        //        // default behaviour
        //        return height
        
        if pullUpViewController.state != .intermediate {
            oldPullState = pullUpViewController.state
        }
        
        let tipViewController = self.childViewControllers.first as! GTranslateBottomTipViewController
        let recentViewController = self.childViewControllers.last as! GTranslateBottomRecentViewController
        
        if pullUpViewController.state == .expanded {
            tipViewController.tableView.isScrollEnabled = true
            recentViewController.tableView.isScrollEnabled = true
            
            return bottomVC.view.frame.height
        } else if pullUpViewController.state == .intermediate {
            //            if height > (screenSize?.height)! - 70 - 100 {
            //                return bottomVC.view.frame.height
            //            } else {
            //                return minHeight
            //            }
            if oldPullState == .expanded {
                tipViewController.tableView.isScrollEnabled = false
                recentViewController.tableView.isScrollEnabled = false
                
                oldPullState = .collapsed
                return minHeight.rawValue
            } else {
                oldPullState = .expanded
                tipViewController.tableView.isScrollEnabled = true
                recentViewController.tableView.isScrollEnabled = true
                
                
                return bottomVC.view.frame.height
            }
            
        } else {
            tipViewController.tableView.isScrollEnabled = false
            recentViewController.tableView.isScrollEnabled = false
            
            return minHeight.rawValue
        }
    }
    
    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, update edgeInsets: UIEdgeInsets, forBottomViewController bottomVC: UIViewController) {
        //        // we update the scroll view's content inset
        //        // to properly support scrolling in the intermediate states
        //        scrollView.contentInset = edgeInsets;
    }
    
    
    // MARK: ISHPullUpStateDelegate
    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, didChangeTo state: ISHPullUpState) {
        
        //        log.info(pullUpViewController.state.rawValue)
        
        //        topLabel.text = textForState(state);
        //        handleView.setState(ISHPullUpHandleView.handleState(for: state), animated: firstAppearanceCompleted)
    }
}
