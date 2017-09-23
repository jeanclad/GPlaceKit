//
//  GTranslateMainViewController.swift
//  main
//
//  Created by jeanclad on 2017. 3. 29..
//  Copyright © 2017년 interpark-int. All rights reserved.
//

import Foundation
import MobileCoreServices
import AVFoundation
import ISHPullUp
import ObjectMapper

protocol GTranslateMainViewControllerDelegate {
    func gTranslateMainViewControllerLangChanged()
    func gTranslateMainViewControllerAddTempRecentData(recentData: RecentData)
}

class GTranslateMainViewController: UIViewController, UITextViewDelegate,
UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ISHPullUpContentDelegate, GTranslateSpeechControllerDelegate, GTranslateSelectLangViewControllerDelegate, GTranslateVisionPhotoViewContollerDelegate, GTranslateFullTextViewControllerDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var inputLangButton: UIButton!
    @IBOutlet var outputLangButton: UIButton!
    @IBOutlet var inputLangDropButton: UIImageView!
    @IBOutlet var outputLangDropButton: UIImageView!
    @IBOutlet var bottomViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var mainButtonView: UIView!
    @IBOutlet var audioButton: UIButton!
    @IBOutlet var cameraButton: UIButton!
    
    var delegate: GTranslateMainViewControllerDelegate?
    let imagePicker = UIImagePickerController()
    var gTranslateRequestItem = GTranslateRequestItem()
    var textRequestModel = GTranslateTextV2RequestModel()
    var currentSelectedFuntionType = GTranslateConstants.SelectFunctionType.text
    let bgAnimationTime = 0.5
    let cameraMaxSizeRate = CGFloat(1.5)
    
    var typingFinishTimer: Timer?
    var circle: UIView?
    let circleDiameterMax = CGFloat(120)
    let circleDiameterMin = CGFloat(75.0)
    var isMicAnimating = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = ManagerColor().colorFromRGB(GTranslateConstants.ColorBG.text.rawValue)
        
        imagePicker.delegate = self
        
        tableView.estimatedRowHeight = 33
        tableView.rowHeight = UITableViewAutomaticDimension
        
        gTranslateRequestItem.googleApiKey = GTranslateConstants.Url().getGoogleAPIKey()
        
        if gTranslateRequestItem.googleApiKey != nil {
            textRequestModel.key = gTranslateRequestItem.googleApiKey
            textRequestModel.format = gTranslateRequestItem.format
            
            CommonAPI.sharedInstance.httpRequestGTranslateGetLangCode(completionHandler: { (response) in
                let responseModel: GTranslateLangCodeModel = response
                if responseModel.result == true {
                    responseModel.gData?.sort(by: { $0.priority! < $1.priority! })
                    ManagerTranslate.sharedInstance.setCodeModel(model: responseModel)
                    
                    // TODO: 차후 예약 API에서 언어쌍을 설정해줘야 함
                    self.configureHeaderLangSet(srcLangCode:
                        ManagerTranslate.sharedInstance.defaultSrcLangCode,
                                                dstLangCode:
                        ManagerTranslate.sharedInstance.defaultDstLangCode)
                }
            }, errorHandler: { (error) in
                
            })
            
            configureHeaderDefaultLangSet()
        } else {
            Alert().showAlert(GTranslateConstants.Text().getTextFailDefault(code: GTranslateConstants.Error.Code.cannot_find_api_key.rawValue))
        }
        
        if #available(iOS 10.0, *) {
            GTranslateSpeechController.sharedInstance.prepare()
            GTranslateSpeechController.sharedInstance.delegate = self
        } else {
            audioButton.isEnabled = false
        }
        
        if TARGET_IPHONE_SIMULATOR != 1 &&
            UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) == false {
            cameraButton.isEnabled = false
        }
        
        //        let menuNaver = UIMenuItem(title: "네이버", action: #selector(menuNaverAction))
        //        let menuGoogle = UIMenuItem(title: "구글", action: #selector(menuGoogleAction))
        //
        //        UIMenuController.shared.menuItems = [menuNaver, menuGoogle]
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Google SDK - Analytics
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: (kGAIBuilderTimingCategoryApp + "-" + self.title!))
        
        let build = (GAIDictionaryBuilder.createScreenView().build() as NSDictionary) as! [AnyHashable: Any]
        tracker?.send(build)
        
        // Notification
        let center = NotificationCenter.default
        center.addObserver(self,
                           selector: #selector(keyboardWillShow(_:)),
                           name: .UIKeyboardWillShow,
                           object: nil)
        
        center.addObserver(self,
                           selector: #selector(keyboardWillHide(_:)),
                           name: .UIKeyboardWillHide,
                           object: nil)
        
        if #available(iOS 10.0, *) {
            // 음성 번역중에 다른화면으로 갔다가 똘아온 경우 입력글자가 없으면 텍스트 번역 초기상태로 변경한다.
            if currentSelectedFuntionType == GTranslateConstants.SelectFunctionType.audio {
                if gTranslateRequestItem.textItem.input.utf16.count < 1 {
                    currentSelectedFuntionType = GTranslateConstants.SelectFunctionType.text
                    
                    UIView.animate(withDuration: bgAnimationTime, animations: {
                        self.view.backgroundColor = ManagerColor().colorFromRGB(GTranslateConstants.ColorBG.text.rawValue)
                    })
                    
                    bottomViewHeightConstraint.constant = GTranslateConstants.BottomViewHeight.mid.rawValue
                    let userInfo = ["state": GTranslateConstants.BottomViewState.mid]
                    
                    let notificationName = Notification.Name(GTranslateConstants.INotification().getBottomViewMoveNotificationId())
                    NotificationCenter.default.post(name: notificationName, object: nil, userInfo: userInfo)
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if #available(iOS 10.0, *) {
            ManagerTTS.sharedInstance.ttsStop()
            
            if currentSelectedFuntionType == GTranslateConstants.SelectFunctionType.audio {
                audioButton.isSelected = false
                circle?.isHidden = true
                GTranslateSpeechController.sharedInstance.stopRecording()
            }
        }
        
        typingFinishTimer?.invalidate()
        typingFinishTimer = nil
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: Private Method
    fileprivate func requestTextTranslate(isRefreshTableHeight: Bool, isRecentSave: Bool) {
        //        if gTranslateRequestItem.textItem.input.utf16.count > 0 {
        textRequestModel.q = gTranslateRequestItem.textItem.input
        
        let indexPath = IndexPath.init(row: GTranslateConstants.TextViewCellIndex.outputCellIndex.rawValue, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! OutputTextViewTableViewCell
        cell.outputTextView.text = cell.outputTextView.text + GTranslateConstants.Text().getTextOutputLoading()
        
        CommonAPI.sharedInstance.httpRequestGTranslateTextV2(params: textRequestModel, completionHandler: { (response) in
            
            let responseModel : GTranslateTextV2ResponseModel = response
            
            log.info(responseModel.data?.translations?.first?.translatedText)
            
            self.gTranslateRequestItem.textItem.output = (responseModel.data?.translations?.first?.translatedText)!.removingPercentEncoding!
            
            let indexPath = IndexPath(item: GTranslateConstants.TextViewCellIndex.outputCellIndex.rawValue, section: 0)
            if let visibleIndexPaths = self.tableView.indexPathsForVisibleRows?.index(of: indexPath as IndexPath) {
                if visibleIndexPaths != NSNotFound {
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
            
            if isRefreshTableHeight {
                self.refreshTableViewHeight()
            }
            
            if isRecentSave {
                let _ = self.requestAddRecentData()
            }
            
        }, errorHandler: { (error) in
            cell.outputTextView.text = ""
        })
        //        }
    }
    
    fileprivate func requestAddRecentData() -> Bool {
        if gTranslateRequestItem.textItem.input == "" &&
            gTranslateRequestItem.textItem.output == "" {
            return false
        }
        
        var requestParams: [String: String] = [:]
        requestParams["GUID"] = ManagerTranslate.sharedInstance.getRandomID()
        requestParams["memberNO"] = ""
        requestParams["beforeLanguageCode"] = ManagerTranslate.sharedInstance.getSrcLangModel()?.code
        requestParams["afterLanguageCode"] = ManagerTranslate.sharedInstance.getDstLangModel()?.code
        requestParams["beforeConversion"] = gTranslateRequestItem.textItem.input
        requestParams["afterConversion"] = gTranslateRequestItem.textItem.output
        requestParams["os"] = Util.getOSName()
        
        if Session.isSession() {
            requestParams["memberNO"] = Session.getSession(kSessionTempInterparkGuest)
        }
        
        CommonAPI.sharedInstance.httpRequestGTranslateInsertRecentData(requestParams: requestParams, completionHandler: { (response) in
            //let responseModel: GTranslateRecentResponseModel = response
            
            let gRecentData = RecentData()
            gRecentData.beforeLanguageCode = requestParams["beforeLanguageCode"]
            gRecentData.afterLanguageCode = requestParams["afterLanguageCode"]
            gRecentData.beforeConversion = requestParams["beforeConversion"]
            gRecentData.afterConversion = requestParams["afterConversion"]
            
            self.delegate?.gTranslateMainViewControllerAddTempRecentData(recentData: gRecentData)
        }) { (error) in
            
        }
        
        return true
    }
    
    fileprivate func cancelRequestTranslate() {
        CommonAPI.sharedInstance.httpAllRequestCancel()
    }
    
    fileprivate func clearAllTextView() {
        
        gTranslateRequestItem.textItem.input = ""
        gTranslateRequestItem.textItem.output = ""
        
        tableView.reloadData()
    }
    
    fileprivate func refreshTableViewHeight() {
        let currentOffset = tableView.contentOffset
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        tableView.setContentOffset(currentOffset, animated: false)
    }
    
    fileprivate func configureHeaderDefaultLangSet() {
        let model : GTranslateLangCodeModel = Mapper().map(JSON: GTranslateLangDefaultCodeModel().getDefaultCodeModelJson())!
        
        ManagerTranslate.sharedInstance.setCodeModel(model: model)
        ManagerTranslate.sharedInstance.setDefaultDstLangModel()
        
        configureHeaderLangSet(srcLangCode:
            (ManagerTranslate.sharedInstance.getSrcLangModel()?.code)!,
                               dstLangCode:
            (ManagerTranslate.sharedInstance.getDstLangModel()?.code!)!)
    }
    
    fileprivate func configureHeaderLangSet(srcLangCode: String,
                                            dstLangCode: String) {
        ManagerTranslate.sharedInstance.setSrcLangCode(code: srcLangCode)
        ManagerTranslate.sharedInstance.setDstLangCode(code: dstLangCode)
        
        textRequestModel.source = ManagerTranslate.sharedInstance.getSrcLangModel()?.code
        textRequestModel.target = ManagerTranslate.sharedInstance.getDstLangModel()?.code
        
        if srcLangCode == ManagerTranslate.sharedInstance.defaultSrcLangCode {
            inputLangButton.isEnabled = false
            outputLangButton.isEnabled = true
            inputLangDropButton.isHidden = true
            outputLangDropButton.isHidden = false
        } else {
            inputLangButton.isEnabled = false
            outputLangButton.isEnabled = true
            inputLangDropButton.isHidden = false
            outputLangDropButton.isHidden = true
        }
        
        inputLangButton.setTitle(ManagerTranslate.sharedInstance.getSrcLangModel()?.codeName, for: .normal)
        outputLangButton.setTitle(ManagerTranslate.sharedInstance.getDstLangModel()?.codeName, for: .normal)
    }
    
    fileprivate func convertLang(isTranslate: Bool) {
        if #available(iOS 10.0, *) {
            ManagerTTS.sharedInstance.ttsStop()
            
            audioButton.isSelected = false
            circle?.isHidden = true
            GTranslateSpeechController.sharedInstance.stopRecording()
        }
        
        let intputLangCode = ManagerTranslate.sharedInstance.getSrcLangModel()?.code
        let outputLangCode = ManagerTranslate.sharedInstance.getDstLangModel()?.code
        
        if intputLangCode != nil && outputLangCode != nil {
            let intputLangButtonText = inputLangButton.currentTitle
            let outLangButtonText = outputLangButton.currentTitle
            
            inputLangButton.setTitle(outLangButtonText, for: .normal)
            outputLangButton.setTitle(intputLangButtonText, for: .normal)
            
            ManagerTranslate.sharedInstance.setSrcLangCode(code: outputLangCode!)
            ManagerTranslate.sharedInstance.setDstLangCode(code: intputLangCode!)
            
            textRequestModel.source = ManagerTranslate.sharedInstance.getSrcLangModel()?.code
            textRequestModel.target = ManagerTranslate.sharedInstance.getDstLangModel()?.code
            
            if inputLangButton.isEnabled == false {
                inputLangButton.isEnabled = true
                outputLangButton.isEnabled = false
                inputLangDropButton.isHidden = false
                outputLangDropButton.isHidden = true
            } else {
                inputLangButton.isEnabled = false
                outputLangButton.isEnabled = true
                inputLangDropButton.isHidden = true
                outputLangDropButton.isHidden = false
            }
            
            let tmpInputText = gTranslateRequestItem.textItem.input
            gTranslateRequestItem.textItem.input = gTranslateRequestItem.textItem.output
            
            if isTranslate {
                gTranslateRequestItem.textItem.output = ""
                if gTranslateRequestItem.textItem.input.utf16.count > 0 {
                    requestTextTranslate(isRefreshTableHeight: true, isRecentSave: false)
                }
            } else {
                gTranslateRequestItem.textItem.output = tmpInputText
            }
            
            tableView.reloadData()
        }
    }
    
    
    // MARK: Public Method
    public func relateBottomItem(item: GTranslateBottomContentModel) {
        let dummyParam = ""
        textMenuButtonPressed(dummyParam)
        
        ManagerTranslate.sharedInstance.setSrcLangCode(code: item.inputLangCode!)
        textRequestModel.source = ManagerTranslate.sharedInstance.getSrcLangModel()?.code
        
        ManagerTranslate.sharedInstance.setDstLangCode(code: item.outputLangCode!)
        textRequestModel.target = ManagerTranslate.sharedInstance.getDstLangModel()?.code
        
        gTranslateRequestItem.textItem.input = item.inputText!
        gTranslateRequestItem.textItem.output = item.outputText!
        
        if ManagerTranslate.sharedInstance.getSrcLangModel()?.code == ManagerTranslate.sharedInstance.defaultSrcLangCode {
            inputLangButton.isEnabled = false
            outputLangButton.isEnabled = true
            inputLangDropButton.isHidden = true
            outputLangDropButton.isHidden = false
        } else {
            inputLangButton.isEnabled = true
            outputLangButton.isEnabled = false
            inputLangDropButton.isHidden = false
            outputLangDropButton.isHidden = true
        }
        
        tableView.reloadData()
        refreshTableViewHeight()
        
        inputLangButton.setTitle(ManagerTranslate.sharedInstance.getSrcLangModel()?.codeName, for: .normal)
        outputLangButton.setTitle(ManagerTranslate.sharedInstance.getDstLangModel()?.codeName, for: .normal)
        
        bottomViewHeightConstraint.constant = GTranslateConstants.BottomViewHeight.min.rawValue
        let userInfo = ["state": GTranslateConstants.BottomViewState.down]
        
        let notificationName = Notification.Name(GTranslateConstants.INotification().getBottomViewMoveNotificationId())
        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: userInfo)
    }
    
    
    // MARK: Actions
    @IBAction func backButtonPressed(_ sender: Any) {
        cancelRequestTranslate()
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cameraMenuButtonPressed(_ sender: Any) {
        cancelRequestTranslate()
        
        let notSupported = "NotSupported"
        if ManagerTranslate.sharedInstance.getSrcLangModel()?.visionCode == notSupported {
            Alert().showAlert(GTranslateConstants.Text().getTextVisionNotSupportedLang())
            return
        }
        
        if ManagerTranslate.sharedInstance.getDstLangModel()?.visionCode == notSupported {
            Alert().showAlert(GTranslateConstants.Text().getTextVisionNotSupportedLang())
            return
        }

        
        if gTranslateRequestItem.googleApiKey != nil {
            currentSelectedFuntionType = GTranslateConstants.SelectFunctionType.camera
            
            
            if audioButton.isSelected {
                if #available(iOS 10.0, *) {
                    audioButton.isSelected = false
                    circle?.isHidden = true
                    GTranslateSpeechController.sharedInstance.stopRecording()
                }
            }
            
            imagePicker.allowsEditing = false
            
            if TARGET_IPHONE_SIMULATOR == 1 {
                //simulator
                imagePicker.sourceType = .photoLibrary
                present(imagePicker, animated: true, completion: nil)
            } else {
                //device
                imagePicker.sourceType = .camera
                imagePicker.mediaTypes = [kUTTypeImage as String]
                present(imagePicker, animated: true, completion: nil)
            }
            
        } else {
            Alert().showAlert(GTranslateConstants.Text().getTextFailDefault(code: GTranslateConstants.Error.Code.cannot_find_api_key.rawValue))
        }
    }
    
    @IBAction func audioButtonPressed(_ sender: Any) {
        if #available(iOS 10.0, *) {
            let button = sender as! UIButton
            
            if button.isSelected == true {
                button.isSelected = false
                
                tableView.reloadData()
                
                if gTranslateRequestItem.textItem.input.utf16.count < 1 {
                    currentSelectedFuntionType = GTranslateConstants.SelectFunctionType.text
                    
                    UIView.animate(withDuration: bgAnimationTime, animations: {
                        self.view.backgroundColor = ManagerColor().colorFromRGB(GTranslateConstants.ColorBG.text.rawValue)
                    })
                    
                    bottomViewHeightConstraint.constant = GTranslateConstants.BottomViewHeight.mid.rawValue
                    let userInfo = ["state": GTranslateConstants.BottomViewState.mid]
                    
                    let notificationName = Notification.Name(GTranslateConstants.INotification().getBottomViewMoveNotificationId())
                    NotificationCenter.default.post(name: notificationName, object: nil, userInfo: userInfo)
                }
                
                audioButton.isSelected = false
                circle?.isHidden = true
                GTranslateSpeechController.sharedInstance.stopRecording()
                
                // 기존의 request는 모두 무시하고 final request로 데이터를 처리힌다.
                if gTranslateRequestItem.textItem.input != "" {
                    cancelRequestTranslate()
                    requestTextTranslate(isRefreshTableHeight: false, isRecentSave: true)
                }
            } else {
                currentSelectedFuntionType = GTranslateConstants.SelectFunctionType.audio
                
                UIView.animate(withDuration: bgAnimationTime, animations: {
                    self.view.backgroundColor = ManagerColor().colorFromRGB(GTranslateConstants.ColorBG.audio.rawValue)
                })
                
                button.isSelected = true
                circle?.isHidden = false
                
                GTranslateSpeechController.sharedInstance.stopRecording()
                
                cancelRequestTranslate()
                
                clearAllTextView()
                
                bottomViewHeightConstraint.constant = GTranslateConstants.BottomViewHeight.min.rawValue
                let userInfo = ["state": GTranslateConstants.BottomViewState.down]
                
                let notificationName = Notification.Name(GTranslateConstants.INotification().getBottomViewMoveNotificationId())
                NotificationCenter.default.post(name: notificationName, object: nil, userInfo: userInfo)
                
                
                tableView.reloadData()
                
                let speechLangCode = ManagerTranslate.sharedInstance.getSrcLangModel()?.speechCodeIOS
                GTranslateSpeechController.sharedInstance.startRecording(locale: Locale(identifier: speechLangCode!))
            }
        } else {
            Alert().showAlert(GTranslateConstants.Text().getTextSpeechFailOSVersion())
        }
    }
    
    @IBAction func textMenuButtonPressed(_ sender: Any) {
        if gTranslateRequestItem.googleApiKey != nil {
            cancelRequestTranslate()
            
            if #available(iOS 10.0, *) {
                ManagerTTS.sharedInstance.ttsStop()
            }
            
            currentSelectedFuntionType = GTranslateConstants.SelectFunctionType.text
            
            UIView.animate(withDuration: bgAnimationTime, animations: {
                self.view.backgroundColor = ManagerColor().colorFromRGB(GTranslateConstants.ColorBG.text.rawValue)
            })
            
            if audioButton.isSelected {
                if #available(iOS 10.0, *) {
                    audioButton.isSelected = false
                    circle?.isHidden = true
                    GTranslateSpeechController.sharedInstance.stopRecording()
                }
            }
            
            clearAllTextView()
            
            bottomViewHeightConstraint.constant = GTranslateConstants.BottomViewHeight.mid.rawValue
            let userInfo = ["state": GTranslateConstants.BottomViewState.mid]
            
            let notificationName = Notification.Name(GTranslateConstants.INotification().getBottomViewMoveNotificationId())
            NotificationCenter.default.post(name: notificationName, object: nil, userInfo: userInfo)
            
            tableView.setContentOffset(CGPoint.zero, animated: true)
            
            let indexPath = IndexPath.init(row: GTranslateConstants.TextViewCellIndex.inputCellIndex.rawValue, section: 0)
            let cell = tableView.cellForRow(at: indexPath) as! InputTextViewTableViewCell
            
            cell.inputTextView.becomeFirstResponder()
        } else {
            Alert().showAlert("서비스에 불편을 드려서 죄송합니다.(\(GTranslateConstants.Error.Code.cannot_find_api_key.rawValue))")
        }
        
    }
    
    @IBAction func textViewClearButtonPressed(_ sender: Any) {
        cancelRequestTranslate()
        
        UIView.animate(withDuration: bgAnimationTime, animations: {
            self.view.backgroundColor = ManagerColor().colorFromRGB(GTranslateConstants.ColorBG.text.rawValue)
        })
        
        if #available(iOS 10.0, *) {
            audioButton.isSelected = false
            circle?.isHidden = true
            GTranslateSpeechController.sharedInstance.stopRecording()
            
            ManagerTTS.sharedInstance.ttsStop()
        }
        
        clearAllTextView()
        
        bottomViewHeightConstraint.constant = GTranslateConstants.BottomViewHeight.mid.rawValue
        let userInfo = ["state": GTranslateConstants.BottomViewState.mid]
        
        let notificationName = Notification.Name(GTranslateConstants.INotification().getBottomViewMoveNotificationId())
        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: userInfo)
    }
    
    @IBAction func convertLangButtonPressed(_ sender: Any) {
        cancelRequestTranslate()
        
        convertLang(isTranslate: false)
    }
    
    
    // MARK: Selector
    func keyboardWillShow(_ notification: Notification) {
        if #available(iOS 10.0, *) {
            ManagerTTS.sharedInstance.ttsStop()
        }
        
        let indexPath = IndexPath.init(row: GTranslateConstants.TextViewCellIndex.inputCellIndex.rawValue, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! InputTextViewTableViewCell
        cell.clearTextButton.isHidden = false
    }
    
    func keyboardWillHide(_ notification: Notification) {
        //        let indexPath = IndexPath.init(row: GTranslateConstants.TextViewCellIndex.inputCellIndex.rawValue, section: 0)
        //        let cell = tableView.cellForRow(at: indexPath) as! InputTextViewTableViewCell
        //
        //        if cell.inputTextView.text.utf16.count == 0 {
        //            cell.clearTextButton.isHidden = true
        //        }
        
        // WORKARROUD: 스크롤상의 위치가 inputCell이 visible상태가 아닌경우 cell을 불러오면 nil로 인해 crash 발생방어
        //        tableViㄱew.reloadData()
    }
    
    func runTranslate() {
        typingFinishTimer?.invalidate()
        typingFinishTimer = nil
        
        requestTextTranslate(isRefreshTableHeight: false, isRecentSave: false)
    }
    
    func menuNaverAction(sender: UIMenuItem) {
        print("menuNaverAction")
        
        //        var indexPath = IndexPath.init(row: GTranslateConstants.TextViewCellIndex.inputCellIndex.rawValue, section: 0)
        //        if let cell = tableView.cellForRow(at: indexPath) as? InputTextViewTableViewCell {
        //            let inputCell = tableView.cellForRow(at: indexPath) as! InputTextViewTableViewCell
        //            if let textRange = inputCell.inputTextView.selectedRange {
        //                let selectedText = inputCell.inputTextView.text(in: textRange)
        //            }
        //        } else {
        //
        //        }
        
        //        var queryString: String?
        //        var url: URL?
        //
        //
        //        var indexPath = IndexPath.init(row: GTranslateConstants.TextViewCellIndex.inputCellIndex.rawValue, section: 0)
        //        var cell: UITableViewCell? = tableView.cellForRow(at: indexPath)
        //
        //        if cell == nil {
        //            indexPath = IndexPath.init(row: GTranslateConstants.TextViewCellIndex.outputCellIndex.rawValue, section: 0)
        //            cell = tableView.cellForRow(at: indexPath) as! OutputTextViewTableViewCell
        //
        //        } else {
        //            let inputCell = cell as? InputTextViewTableViewCell
        //            if let textRange = inputCell?.inputTextView.selectedRange {
        //                let selectedText = inputCell?.inputTextView.text(in: textRange)
        //                queryString = selectedText
        //
        //                url = URL(string: "https://search.naver.com/search.naver?query=" + (queryString?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!)!
        //            }
        //
        //
        //        }
        //
        //        if url != nil {
        //            if UIApplication.shared.canOpenURL(url!) {
        //                UIApplication.shared.openURL(url!)
        //            }
        //        }
        
    }
    
    func menuGoogleAction(sender: UIMenuItem) {
        print("menuGoogleAction")
    }
    
    // MARK: ISHPullUpContentDelegate
    func pullUpViewController(_ vc: ISHPullUpViewController, update edgeInsets: UIEdgeInsets, forContentViewController _: UIViewController) {
        // update edgeInsets
        view.layoutMargins = edgeInsets
        
        // call layoutIfNeeded right away to participate in animations
        // this method may be called from within animation blocks
        view.layoutIfNeeded()
    }
    
    
    // MARK: GTranslateSpeechControllerDelegate
    func GTranslateSpeechControllerDelegateAuth(isEnabled: Bool) {
        if isEnabled == false {
            audioButton.isEnabled = false
        } else {
            if circle == nil {
                circle = UIView(frame: CGRect(x: 0,
                                              y: 0,
                                              width: circleDiameterMin,
                                              height: circleDiameterMin))
                circle?.center = audioButton.center
                circle?.layer.cornerRadius = (circle?.bounds.width)! / 2
                circle?.backgroundColor = ManagerColor().colorFromRGB(0x7e035b, alpha: 0.3)
                circle?.clipsToBounds = true
                circle?.isHidden = true
                
                mainButtonView.insertSubview(circle!, belowSubview: audioButton)
            }
        }
    }
    
    func GTranslateSpeechControllerFinished() {
        audioButton.isSelected = false
        circle?.isHidden = true
        if #available(iOS 10.0, *) {
            GTranslateSpeechController.sharedInstance.stopRecording()
            
            // 번역 텍스트뷰의 ttsButton, fullTextButton을 활성화 시키기 위함
            tableView.reloadData()
            
            let _ = requestAddRecentData()
        }
    }
    
    func GTranslateSpeechControllerDelegateResultText(message: String, isFinal: Bool) {
        gTranslateRequestItem.textItem.input = message
        
        tableView.reloadData()
        
        requestTextTranslate(isRefreshTableHeight: true, isRecentSave: false)
    }
    
    func GTranslateSpeechControllerAudioVolume(volume: Float) {
        let virtualVolume = CGFloat(volume * 100000)
        //        log.info("dia = \(virtualVolume)")
        
        let guage = circleDiameterMax - circleDiameterMin
        
        var diameter = virtualVolume / guage + circleDiameterMin
        
        if diameter < circleDiameterMin {
            diameter = circleDiameterMin
        }
        
        if diameter > circleDiameterMax {
            diameter = circleDiameterMax
        }
        
        let circleSize = CGSize(width: diameter, height: diameter)
        
        DispatchQueue.main.async(execute: {
            if self.isMicAnimating == false {
                self.isMicAnimating = true
                
                UIView.animate(withDuration: 0.1, animations: {
                    self.circle?.frame.size.width = circleSize.width
                    self.circle?.frame.size.height = circleSize.height
                    self.circle?.layer.cornerRadius = (self.circle?.bounds.width)! / 2
                    self.circle?.center = self.audioButton.center
                    self.circle?.setNeedsDisplay()
                    self.circle?.setNeedsLayout()
                }) { (complete) in
                    self.isMicAnimating = false
                }
            }
        })
    }
    
    
    // MARK: GTranslateSelectLangViewControllerDelegate
    func GTranslateSelectLangViewControllerDelegate(myType: GTranslateConstants.SelectLangType, model: GData) {
        if myType == GTranslateConstants.SelectLangType.inputLang {
            inputLangButton.setTitle(model.codeName, for: .normal)
            textRequestModel.source = model.code
        } else {
            if textRequestModel.target != model.code {
                outputLangButton.setTitle(model.codeName, for: .normal)
                textRequestModel.target = model.code
                
                requestTextTranslate(isRefreshTableHeight: true, isRecentSave: true)
            }

        }
        
        delegate?.gTranslateMainViewControllerLangChanged()
    }
    
    
    // MARK: GTranslateVisionPhotoViewControllerDelegate
    func gTranslateVisionPhotoViewContollerRestart() {
        let dummyParam = ""
        cameraMenuButtonPressed(dummyParam)
    }
    
    func gTranslateVisionPhotoViewControllerAudioStart() {
        convertLang(isTranslate: false)
        
        bottomViewHeightConstraint.constant = GTranslateConstants.BottomViewHeight.min.rawValue
        let userInfo = ["state": GTranslateConstants.BottomViewState.down]
        
        let notificationName = Notification.Name(GTranslateConstants.INotification().getBottomViewMoveNotificationId())
        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: userInfo)
        
        audioButtonPressed(audioButton)
    }
    
    func gTranslateVisionPhotoViewwControllerAddTempRecentData(recentData: RecentData) {
       delegate?.gTranslateMainViewControllerAddTempRecentData(recentData: recentData)
    }
    
    
    // MARK: GTranslateFullTextViewControllerDelegate
    func gTranslateFullTextViewControllerAudioStart() {
        convertLang(isTranslate: false)
        
        audioButtonPressed(audioButton)
    }
    
    
    // MARK: UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == GTranslateConstants.TextViewCellIndex.inputCellIndex.rawValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: "InputTextViewTableViewCell", for: indexPath) as! InputTextViewTableViewCell
            if cell.inputTextView.delegate == nil {
                cell.inputTextView.delegate = self
            }
            cell.inputTextView.text = gTranslateRequestItem.textItem.input
            
            if cell.inputTextView.text.utf16.count > 0 {
                cell.showPlaceHolderText(isHidden: true)
                cell.clearTextButton.isHidden = false
            } else {
                cell.showPlaceHolderText(isHidden: false)
                cell.clearTextButton.isHidden = true
            }
            
            if currentSelectedFuntionType == GTranslateConstants.SelectFunctionType.audio {
                cell.placeTextLabel.text = GTranslateConstants.Text().getTextInputPlaceHolderTitle(type: GTranslateConstants.SelectFunctionType.audio)
            } else {
                cell.placeTextLabel.text = GTranslateConstants.Text().getTextInputPlaceHolderTitle(type: GTranslateConstants.SelectFunctionType.text)
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OutputTextViewTableViewCell", for: indexPath) as! OutputTextViewTableViewCell
            if cell.outputTextView.delegate == nil {
                cell.outputTextView.delegate = self
            }
            cell.outputTextView.text = gTranslateRequestItem.textItem.output
            
            if cell.outputTextView.text.utf16.count > 0 {
                if #available(iOS 10.0, *) {
                    if !GTranslateSpeechController.sharedInstance.isRunning() {
                        cell.ttsButton.isHidden = false
                        cell.fullTextButton.isHidden = false
                    }
                } else {
                    cell.ttsButton.isHidden = false
                    cell.fullTextButton.isHidden = false
                }
            } else {
                cell.ttsButton.isHidden = true
                cell.fullTextButton.isHidden = true
            }
            
            return cell
        }
    }
    
    
    // MARK: UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        refreshTableViewHeight()
        
        if textView.tag == 1 {
            gTranslateRequestItem.textItem.input = textView.text
            
            typingFinishTimer?.invalidate()
            typingFinishTimer = nil
            typingFinishTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTranslate), userInfo: nil, repeats: false)
            
            let indexPath = IndexPath(row: GTranslateConstants.TextViewCellIndex.inputCellIndex.rawValue, section: 0)
            let cell = tableView.cellForRow(at: indexPath) as! InputTextViewTableViewCell
            
            if gTranslateRequestItem.textItem.input.utf16.count > 0 {
                cell.showPlaceHolderText(isHidden: true)
            } else {
                cell.showPlaceHolderText(isHidden: false)
            }
            
            var userInfo: [String: GTranslateConstants.BottomViewState] = [:]
            
            if !textView.text.isEmpty {
                bottomViewHeightConstraint.constant = GTranslateConstants.BottomViewHeight.min.rawValue
                userInfo = ["state": GTranslateConstants.BottomViewState.down]
            } else {
                bottomViewHeightConstraint.constant = GTranslateConstants.BottomViewHeight.mid.rawValue
                userInfo = ["state": GTranslateConstants.BottomViewState.mid]
            }
            
            let notificationName = Notification.Name(GTranslateConstants.INotification().getBottomViewMoveNotificationId())
            NotificationCenter.default.post(name: notificationName, object: nil, userInfo: userInfo)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            cancelRequestTranslate()
            requestTextTranslate(isRefreshTableHeight: false, isRecentSave: true)
            textView.resignFirstResponder()
            
            return false
        }
        
        return true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if audioButton.isSelected {
            return false
        }
        
        return true
    }
    
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        dismiss(animated: true, completion:nil)
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            clearAllTextView()
            
            bottomViewHeightConstraint.constant = GTranslateConstants.BottomViewHeight.mid.rawValue
            let userInfo = ["state": GTranslateConstants.BottomViewState.mid]
            
            let notificationName = Notification.Name(GTranslateConstants.INotification().getBottomViewMoveNotificationId())
            NotificationCenter.default.post(name: notificationName, object: nil, userInfo: userInfo)
            
            
            log.info("pickedImage Width = \(pickedImage.size.width), height = \(pickedImage.size.height)")
            
            let imageWidth = pickedImage.size.width
            let imageHeight = pickedImage.size.height
            
            var resizeImage = pickedImage
            
            // 이미지 최대크기를 스크린 해상도의 cameraMaxSizeRate배로 제한
            let deviceWidth = UIScreen.main.bounds.width * cameraMaxSizeRate
            let deviceHeight = UIScreen.main.bounds.height * cameraMaxSizeRate
            
            if imageWidth > deviceWidth ||
                imageHeight > deviceHeight {
                
                var targetSize: CGFloat
                
                //                    if imageWidth <= imageHeight {
                //                        targetSize = deviceHeight * imageWidth / imageHeight
                //                        resizeImage = ManagerImage().resizeImageToImage(pickedImage, targetSize: CGSize(width: targetSize, height: deviceHeight))
                //                    } else {
                //                        targetSize = deviceWidth * imageHeight / imageWidth
                //                        resizeImage = ManagerImage().resizeImageToImage(pickedImage, targetSize: CGSize(width: deviceWidth, height: targetSize))
                //                    }
                if imageWidth <= imageHeight {
                    targetSize = deviceWidth * imageHeight / imageWidth
                    resizeImage = ManagerImage().resizeImageToImage(pickedImage, targetSize: CGSize(width: deviceWidth, height: targetSize))
                } else {
                    targetSize = deviceHeight * imageWidth / imageHeight
                    resizeImage = ManagerImage().resizeImageToImage(pickedImage, targetSize: CGSize(width: deviceWidth, height: targetSize))
                }
            }
            
            let imageData = UIImageJPEGRepresentation(resizeImage, GTranslateConstants().TRANSLATE_PHOTO_JPEG_COMPRESS)
            
            let compressImage = UIImage(data: imageData!)
            
            self.performSegue(withIdentifier: "photoView", sender: compressImage)
        }
    }
    
    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination.isKind(of: GTranslateVisionPhotoViewContoller.classForCoder()) == true {
            
            let image = sender as? UIImage
            let dest = segue.destination as! GTranslateVisionPhotoViewContoller
            
            if textRequestModel.target! == ManagerTranslate.sharedInstance.defaultSrcLangCode {
                dest.textRequestModel = textRequestModel
            } else {
                let model = GTranslateTextV2RequestModel()
                model.key = textRequestModel.key
                model.target = textRequestModel.source
                model.source = textRequestModel.target
                model.format = textRequestModel.format
                
                dest.textRequestModel = model
            }
            
            dest.pickedImage = image
            dest.delegate = self
        } else if segue.destination.isKind(of: GTranslateSelectLangViewController.classForCoder()) == true {
            
            let dest = segue.destination as! GTranslateSelectLangViewController
            
            if segue.identifier == GTranslateConstants.SelectLangType.inputLang.rawValue {
                dest.myType = GTranslateConstants.SelectLangType.inputLang
                dest.currentLangModel = ManagerTranslate.sharedInstance.getSrcLangModel()
            } else {
                dest.myType = GTranslateConstants.SelectLangType.outputLang
                dest.currentLangModel = ManagerTranslate.sharedInstance.getDstLangModel()
            }
            
            dest.delegate = self
            
        } else if segue.destination.isKind(of: GTranslateFullTextViewController.classForCoder()) == true {
            let dest = segue.destination as! GTranslateFullTextViewController
            dest.selectedFunctionType = currentSelectedFuntionType
            dest.delegate = self
            
            dest.text = gTranslateRequestItem.textItem.output
        }
    }
}

class InputTextViewTableViewCell: UITableViewCell {
    @IBOutlet var inputTextView: UITextView!
    @IBOutlet var placeTextLabel: UILabel!
    @IBOutlet var clearTextButton: UIButton!
    
    func showPlaceHolderText(isHidden: Bool) {
        if isHidden {
            placeTextLabel.isHidden = true
        } else {
            placeTextLabel.text = GTranslateConstants.Text().getTextInputPlaceHolderTitle(type: .text)
            placeTextLabel.isHidden = false
        }
    }
}

class OutputTextViewTableViewCell: UITableViewCell {
    @IBOutlet var outputTextView: UITextView!
    @IBOutlet var ttsButton: UIButton!
    @IBOutlet var fullTextButton: UIButton!
    
    let synthesizer = AVSpeechSynthesizer()
    
    @IBAction func ttsButtonPressed(_ sender: Any) {
        let speechLangCode = ManagerTranslate.sharedInstance.getDstLangModel()?.speechCodeIOS
        
        ManagerTTS.sharedInstance.ttsStart(lang: speechLangCode!, text: outputTextView.text)
    }
}

