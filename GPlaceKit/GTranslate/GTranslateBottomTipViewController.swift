//
//  GTranslateBottomTipViewController.swift
//  main
//
//  Created by jeanclad on 2017. 5. 24..
//  Copyright © 2017년 interpark-int. All rights reserved.
//

import Foundation
import Kingfisher
import ObjectMapper

protocol GTranslateBottomTipViewControllerDelegate {
    func gTranslateBottomTipViewControllerSelectedItem(item: GTranslateBottomContentModel)
}

class GTranslateBottomTipViewController: GTranslateBottomBaseTableViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var selectedCategoryIndex: Int = 0
    var delegate: GTranslateBottomTipViewControllerDelegate?
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setType(type: GTranslateConstants.SelectBottomCategory.tip)
        
        CommonAPI.sharedInstance.httpRequestGTranslateGetTipCode(completionHandler: { (response) in
            let responseModel: GTranslateLangCodeModel = response
            if responseModel.result == true {
                responseModel.gData?.sort(by: { $0.priority! < $1.priority! })
                
                ManagerTranslate.sharedInstance.setTipCategoryModel(model: responseModel)
                
                let tipJson = GTranslateConstants.IUserDefault().loadTipData()
                if tipJson == nil {
                    CommonAPI.sharedInstance.httpRequestGTranslateGetTipData(completionHandler: { (response) in
                        self.relatetTipData(response: response, isSave: true)
                    }, errorHandler: { (error) in
                        
                    })
                } else {
                    let responseDB = Mapper<GTranslateTipDataResponseModel>().map(JSONString: tipJson!)
                    CommonAPI.sharedInstance.httpRequestGTranslateGetTipData(
                        dataVersion:(responseDB?.tipData?.gVersions?.last?.version)!,
                        completionHandler: { (response) in
                            
                            var myResponse = responseDB
                            var isSave = false
                            
                            if (response.tipData?.statusSets?.count)! > 0 {
                                myResponse = response
                                isSave = true
                            }
                            
                            // 방어로직 : DB or API 값이 버그로 인해 UI를 표시할 데이터가 없다면 디폴트 버전 데이터를 재요청한다.
                            if (myResponse?.tipData?.statusSets?.count)! < 1 {
                                CommonAPI.sharedInstance.httpRequestGTranslateGetTipData(completionHandler: { (response) in
                                    self.relatetTipData(response: response, isSave: true)
                                }, errorHandler: { (error) in
                                    
                                })
                            }
                            
                            self.relatetTipData(response: myResponse!, isSave: isSave)
                    }, errorHandler: { (error) in
                        
                    })
                }
            }
            
        }, errorHandler: { (error) in
            
        })
    }
    
    // MARK: Private
    fileprivate func relatetTipData(response : GTranslateTipDataResponseModel, isSave: Bool) {
        let responseModel: GTranslateTipDataResponseModel = response
        if responseModel.result == true {
            print("JSON: \(response)")
            ManagerTranslate.sharedInstance.setTipDatayModel(model: responseModel)
            self.showCatetoryIndex(index: 0)
            
            if isSave {
                GTranslateConstants.IUserDefault().saveTipData(json: responseModel.toJSONString()!)
            }
        }
    }
    
    fileprivate func showCatetoryIndex(index: Int) {
        selectedCategoryIndex = index
        
        let statusCode = ManagerTranslate.sharedInstance.getTipCategoryModel()?.gData?[selectedCategoryIndex].code
        if statusCode != nil {
            let statusSet = ManagerTranslate.sharedInstance.getTipStatusSetsFromCode(code: statusCode!)
            setTipBook(statusSet: statusSet)
            
            tableView.reloadData()
            collectionView.reloadData()
        }
    }
    
    
    // MARK: PUblic
    public func refreshTableViewControler() {
        tableView.reloadData()
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let currentConversions = getTipConversionsFromIndex(index: indexPath.row)
        
        let bottomContentModel = GTranslateBottomContentModel()
        bottomContentModel.inputLangCode = currentConversions?[srcLangIndex]?.languageCode
        bottomContentModel.outputLangCode = currentConversions?[dstLangIndex]?.languageCode
        bottomContentModel.inputText = currentConversions?[srcLangIndex]?.conversion
        bottomContentModel.outputText = currentConversions?[dstLangIndex]?.conversion
        
        delegate?.gTranslateBottomTipViewControllerSelectedItem(item: bottomContentModel)
    }
    
    // MARK: UICollectionViewDelegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.row % 2 == 1 {
            return CGSize(width: 50, height: 77)
        }
        
        return CGSize(width: 35, height: 77)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row % 2 == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryDotCell", for: indexPath)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryIconCell", for: indexPath)  as! CagetogoryCollectionViewCell
            
            let index = indexPath.row / 2
            let tipData = ManagerTranslate.sharedInstance.getTipCategoryModel()?.gData?[index]
            
            if selectedCategoryIndex == index {
                if tipData != nil {
                    let imageUrl = URL(string: (tipData?.imgUrlOn)!.replacingOccurrences(of: "\r\n", with: ""))
                    cell.cNameImageView.kf.setImage(with: imageUrl)
                    cell.cNameLabel.textColor = ManagerColor().colorFromRGB(0x3c4247)
                    cell.cNameLabel.text = tipData?.codeName
                }
            } else {
                if tipData != nil {
                    let imageUrl = URL(string: (tipData?.imgUrlOff)!.replacingOccurrences(of: "\r\n", with: ""))
                    cell.cNameImageView.kf.setImage(with: imageUrl)
                    cell.cNameLabel.textColor = ManagerColor().colorFromRGB(0x7e8da0)
                    cell.cNameLabel.text = tipData?.codeName
                }
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row / 2
        
        showCatetoryIndex(index: index)
    }
}

class CagetogoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet var cNameImageView: UIImageView!
    @IBOutlet var cNameLabel: UILabel!
}
