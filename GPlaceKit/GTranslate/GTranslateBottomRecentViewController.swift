//
//  GTranslateBottomRecentViewController.swift
//  main
//
//  Created by jeanclad on 2017. 5. 24..
//  Copyright © 2017년 interpark-int. All rights reserved.
//

import Foundation

protocol GTranslateBottomRecentViewControllerDelegate {
    func gTranslateBottomRecentViewControllerSelectedItem(item: GTranslateBottomContentModel)
}


class GTranslateBottomRecentViewController: GTranslateBottomBaseTableViewController {
    var delegate: GTranslateBottomRecentViewControllerDelegate?
    private let defaultPagingSize = 50
    private var isFetching = false
    private var isLastData = false
    //    private var recentArr: [RecentData]? = []
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setType(type: GTranslateConstants.SelectBottomCategory.recent)
        
        requestRecentGetData(isFromFirstPage: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)        
    }
    
    
    // MARK: Private
    public func requestRecentGetData(isFromFirstPage: Bool) {
        var requestParams = [
            "GUID" : ManagerTranslate.sharedInstance.getRandomID(),
            "memberNO" : "",
            "pageSize" : defaultPagingSize,
            ] as [String : AnyObject]
        
        if Session.isSession() {
            requestParams["memberNO"] = Session.getSession(kSessionTempInterparkGuest) as AnyObject
        }
        
        if (getRecentBook()?.count)! < 1 || isFromFirstPage {
            requestParams["offSet"] = 0 as AnyObject
        } else {
            requestParams["offSet"] = getRecentBook()?.last?.seq as AnyObject
        }
        
        isFetching = true
        CommonAPI.sharedInstance.httpRequestGTranslateGetRecentData(requestParams: requestParams, completionHandler: { (response) in
            let responseModel: GTranslateRecentResponseModel = response
            if responseModel.result == true {
                log.info("Complete Loading Recent Data!")
                //                                self.recentArr = response.recentDatas
                self.setRecentBook(recentDataArr: response.recentDatas!)
                self.tableView.reloadData()
                
                if (responseModel.recentDatas?.count)! < self.defaultPagingSize {
                    self.isLastData = true
                    self.tableView.tableFooterView?.isHidden = true
                }
                
                self.isFetching = false
            }
        }) { (error) in
            self.isFetching = true
            self.tableView.tableFooterView?.isHidden = true
        }
    }
    
    
    // MARK: Public
    public func refreshTableViewControler(recentData: RecentData) {
        insertRecentBook(recentData: recentData)
        tableView.reloadData()
    }
    
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let recentData = getRecentBook()?[indexPath.row]
        
        let bottomContentModel = GTranslateBottomContentModel()
        bottomContentModel.inputLangCode = recentData?.beforeLanguageCode
        bottomContentModel.outputLangCode = recentData?.afterLanguageCode
        bottomContentModel.inputText = recentData?.beforeConversion
        bottomContentModel.outputText = recentData?.afterConversion
        
        delegate?.gTranslateBottomRecentViewControllerSelectedItem(item: bottomContentModel)
    }
    
    // MARK: UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (Int(scrollView.contentOffset.y + scrollView.frame.size.height) ==
            Int(scrollView.contentSize.height + scrollView.contentInset.bottom)) {
            if !isFetching && !isLastData {
                log.info("Loading Recent Data!")
                requestRecentGetData(isFromFirstPage: false)
            }
        }
    }
}
