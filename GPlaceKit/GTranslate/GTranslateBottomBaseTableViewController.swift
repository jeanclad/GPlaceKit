//
//  GTranslateBottomBaseTableViewController.swift
//  main
//
//  Created by jeanclad on 2017. 5. 25..
//  Copyright © 2017년 interpark-int. All rights reserved.
//

import Foundation

protocol GTranslateBottomBaseTableViewControllerDelegate {
    func gTranslateBottomBaseTableViewControllerNeedRequestRecentData()
}

class GTranslateBottomBaseTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    public let srcLangIndex = 0
    public let dstLangIndex = 1
    
    private var tipBook: StatusSet?
    private var recentBook: [RecentData]? = []
    private var currentTipConversions: [Int : [Int : Conversion]]? = [:]
    private var myType: GTranslateConstants.SelectBottomCategory?
    
    // MARK: Public Method
    public func setType(type: GTranslateConstants.SelectBottomCategory) {
        myType = type
    }
    
    public func setTipBook(statusSet: StatusSet?) {
        tipBook = statusSet
        currentTipConversions = [:]
    }
    
    public func getTipBook() -> StatusSet? {
        return tipBook
    }
    
    public func getTipConversionsFromIndex(index: Int) -> [Int : Conversion]? {
        return currentTipConversions?[index]
    }
    
    public func setRecentBook(recentDataArr: [RecentData]) {
        recentBook = recentBook! + recentDataArr
    }
    
    public func getRecentBook() -> [RecentData]? {
        return recentBook
    }
    
    public func insertRecentBook(recentData: RecentData) {
        recentBook?.insert(recentData, at: 0)
    }
        
    // MARK: UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if myType == .tip {
            if tipBook != nil {
                return (tipBook?.groupCoversions?.count)!
            }
            
            return 0
        } else {
            if recentBook != nil {
                return (recentBook?.count)!
            }
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! ItemTableViewCell
        
        if myType == .tip {
            if tipBook != nil {
                var convDic: [Int : Conversion] = [:]
                
                let groupConversion = tipBook?.groupCoversions?[indexPath.row]
                for conversion in (groupConversion?.conversions)! {
                    
                    if conversion.languageCode == ManagerTranslate.sharedInstance.defaultSrcLangCode {
                        cell.inputTextLabel.text = conversion.conversion
                        convDic[srcLangIndex] = conversion
                    }
                    
                    // 입력, 출력언어중 외국어로 판단되는 언어를 Tip Data로 설정한다.
                    var dstLangCode = ManagerTranslate.sharedInstance.getDstLangModel()?.code
                    if dstLangCode == ManagerTranslate.sharedInstance.defaultSrcLangCode {
                        dstLangCode = ManagerTranslate.sharedInstance.getSrcLangModel()?.code
                    }
                    
                    if conversion.languageCode == dstLangCode {
                        cell.outputTextLabel.text = conversion.conversion
                        convDic[dstLangIndex] = conversion
                    }
                    
                    if convDic.count > 1 {
                        currentTipConversions?[indexPath.row] = convDic
                    }
                }
            } else {
                cell.inputTextLabel.text = ""
                cell.outputTextLabel.text = ""
            }
            
        } else {
            cell.inputTextLabel.text = recentBook?[indexPath.row].beforeConversion
            cell.outputTextLabel.text = recentBook?[indexPath.row].afterConversion
        }
        
        return cell
    }    
}

class ItemTableViewCell: UITableViewCell {
    @IBOutlet var inputTextLabel: UILabel!
    @IBOutlet var outputTextLabel: UILabel!
    
}
