//
//  GTranslateVisionPhotoViewContoller.swift
//  main
//
//  Created by jeanclad on 2017. 4. 7..
//  Copyright © 2017년 interpark-int. All rights reserved.
//

import Foundation
import Shimmer

protocol GTranslateVisionPhotoViewContollerDelegate {
    func gTranslateVisionPhotoViewContollerRestart()
    func gTranslateVisionPhotoViewControllerAudioStart()
    func gTranslateVisionPhotoViewwControllerAddTempRecentData(recentData: RecentData)
}

class GTranslateVisionPhotoViewContoller: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, GTranslateFullTextViewControllerDelegate {
    
    @IBOutlet var inputLangButton: UIButton!
    @IBOutlet var outputLangButton: UIButton!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var headerView: UIView!
    
    @IBOutlet var zoomScrollView: UIScrollView!
    @IBOutlet var itemView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var lineImageView: UIImageView!
    @IBOutlet var selectedLineImageView: UIImageView!
    @IBOutlet var tempImageView: UIImageView!
    @IBOutlet var drawingBrushImageView: UIImageView!
    
    @IBOutlet var coachView: UIView!
    
    var snackBarLoadingView: FBShimmeringView!
    
    var apiKey: String?
    var textRequestModel = GTranslateTextV2RequestModel()
    
    var pickedImage: UIImage?
    var responseModel : GTranslateVisionV1TextResponseModel?
    var boxRectsDic: [Int: [String: AnyObject]] = [:]
    var selectedBoxStringDic: [Int: String]? = [:]
    var selectedBoxStringArrTuple: [(Int, String)] = []
    
    var inputText: String = ""
    var outputText: String = ""
    
    var imageScale: CGFloat?
    
    var panGestureRecognizer: UIPanGestureRecognizer?
    
    var lastPoint = CGPoint.zero
    var swiped = false
    var brushWidth: CGFloat = 24.0
    let imageDefultAlpha : CGFloat = 0.5
    let pencelOpacity: CGFloat = 0.3
    let lineWIdth : CGFloat = 2
    let lineSelectedColor: UInt = 0x2c9cfe
    var touchFinishTimer: Timer?
    
    var delegate: GTranslateVisionPhotoViewContollerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView.backgroundColor = ManagerColor().colorFromRGB(GTranslateConstants.ColorBG.camera.rawValue)
        tableView.backgroundColor = ManagerColor().colorFromRGB(GTranslateConstants.ColorBG.camera.rawValue)
        
        tableView.estimatedRowHeight = 33
        tableView.rowHeight = UITableViewAutomaticDimension
        
        zoomScrollView.minimumZoomScale = 1.0
        zoomScrollView.maximumZoomScale = 4.0
        zoomScrollView.panGestureRecognizer.minimumNumberOfTouches = 2
        
        apiKey = GTranslateConstants.Url().getGoogleAPIKey()
        
        let intputLang = ManagerTranslate.sharedInstance.getCodeNameFromCode(code: textRequestModel.source!)
        let outputLang = ManagerTranslate.sharedInstance.getCodeNameFromCode(code: textRequestModel.target!)
        
        inputLangButton.setTitle(intputLang, for: .normal)
        outputLangButton.setTitle(outputLang, for: .normal)
        
        initSnackBarView()
        
        if pickedImage != nil {
            showSnackBarLoadingView()
            
            imageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.main.bounds.size)
            imageView.image = self.pickedImage
            
            imageScale = self.imageView.imageScale.width
            
            lineImageView.frame = CGRect(x: lineImageView.frame.origin.x,
                                         y: lineImageView.frame.origin.y,
                                         width: ManagerPoint().getPointWithScale(point: (imageView.image?.size.width)!, scale: imageScale!),
                                         height: ManagerPoint().getPointWithScale(point: (imageView.image?.size.height)!, scale: imageScale!))
            
            lineImageView.center = CGPoint(x: imageView.center.x, y: imageView.center.y)
            selectedLineImageView.frame = lineImageView.frame
            
            tempImageView.frame = lineImageView.frame
            drawingBrushImageView.frame = lineImageView.frame
            
            let image = UIImage.imageWithColor(color: UIColor.init(red: 0, green: 0, blue: 0, alpha: imageDefultAlpha), rect: tempImageView.frame)
            tempImageView.image = image
            drawingBrushImageView.image = image
            
            // Base64 encode the image and create the request
            let binaryImageData = ManagerImage().base64EncodeImage(pickedImage!)
            requestVisionAPIFromImage(binaryImageData: binaryImageData)
        } else {
            Alert().showAlert(GTranslateConstants.Text().getFailLoadImage())
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Google SDK - Analytics
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: (kGAIBuilderTimingCategoryApp + "-" + self.title!))
        
        let build = (GAIDictionaryBuilder.createScreenView().build() as NSDictionary) as! [AnyHashable: Any]
        tracker?.send(build)
        
        touchFinishTimer?.invalidate()
        touchFinishTimer = nil
        
        //        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let isRunCoachGuide = GTranslateConstants.IUserDefault().loadRunCoachGuide()
        if isRunCoachGuide == false {
            GTranslateConstants.IUserDefault().saveRunCoachGuide(isRunCoachGuide: true)
            ManagerAnimation().animateIn(coachView, duration: 0.3, delay: 0, completionHandler: {
                
            })
        } else {
            initGestureAction()
        }
        
        refreshTableViewHeight()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        CommonAPI.sharedInstance.httpAllRequestCancel()
    }
    
    // MARK: Private
    fileprivate func initSnackBarView() {
        // 이미지 로딩 표시 라벨 생성
        snackBarLoadingView = FBShimmeringView(frame: CGRect(x: 0,
                                                             y: headerView.bounds.height - 28,
                                                             width: UIScreen.main.bounds.width,
                                                             height: 28))
        
        let loadingContentView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 28))
        
        let snackBarDimView1 = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 28))
        snackBarDimView1.backgroundColor = UIColor.gray//ManagerColor().colorFromRGB(0x000000)
        snackBarDimView1.alpha = 0.4
        
        
        let loadingMessage = UILabel()
        loadingMessage.text = GTranslateConstants.Text().getTextAnalyzeImage()
        loadingMessage.textAlignment = .center
        loadingMessage.textColor = UIColor.white
        loadingMessage.font = UIFont.systemFont(ofSize: 12)
        loadingMessage.sizeToFit()
        loadingMessage.center = CGPoint(x: (snackBarLoadingView.bounds.width)/2, y: (snackBarLoadingView.bounds.height)/2)
        
        
        loadingContentView.addSubview(snackBarDimView1)
        loadingContentView.addSubview(loadingMessage)
        
        snackBarLoadingView.contentView = loadingContentView
        snackBarLoadingView.isShimmering = true
        snackBarLoadingView.alpha = 0
        
        view.addSubview(snackBarLoadingView)
        
        // snackBarView 위에 코칭가이드뷰가 올라와야 하므로 코칭가이드뷰를 최상단뷰로 설정한다.
        coachView.layer.zPosition = 1
    }
    
    fileprivate func showSnackBarLoadingView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.snackBarLoadingView.alpha = 1
            self.snackBarLoadingView.frame = CGRect(x: (self.snackBarLoadingView?.frame.origin.x)!,
                                                    y: self.headerView.bounds.height,
                                                    width: self.snackBarLoadingView.frame.size.width,
                                                    height: self.snackBarLoadingView.frame.size.height)
        })
    }
    
    fileprivate func hideSnackBarLoadingView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.snackBarLoadingView?.frame = CGRect(x: (self.snackBarLoadingView?.frame.origin.x)!,
                                                     y: self.headerView.bounds.height - self.snackBarLoadingView.bounds.height,
                                                     width: self.snackBarLoadingView!.frame.size.width,
                                                     height: self.snackBarLoadingView!.frame.size.height)
            self.snackBarLoadingView.alpha = 0
        }, completion: { (animate) in
            
        })
    }
    
    fileprivate func requestVisionAPIFromImage(binaryImageData: String) {
        CommonAPI.sharedInstance.httpRequestGTranslateVisionV1Text(params: ["key": apiKey!], lang: textRequestModel.source!, imageBase64: binaryImageData, completionHandler: { (response) in
            
            self.initGestureAction()
            self.hideSnackBarLoadingView()
            
            self.responseModel = response
            
            if self.responseModel?.responses?.first?.textAnnotations != nil {
                for (index, item) in (self.responseModel?.responses?.first?.textAnnotations)!.enumerated() {
                    if index != 0 {
                        if item.boundingPoly?.vertices?[0].x != nil &&
                            item.boundingPoly?.vertices?[0].y != nil &&
                            item.boundingPoly?.vertices?[1].x != nil &&
                            item.boundingPoly?.vertices?[1].y != nil &&
                            item.boundingPoly?.vertices?[2].x != nil &&
                            item.boundingPoly?.vertices?[2].y != nil &&
                            item.boundingPoly?.vertices?[3].x != nil &&
                            item.boundingPoly?.vertices?[3].y != nil {
                            
                            let point1 = ManagerPoint().getPointsWithScale(points:
                                CGPoint(x:CGFloat((item.boundingPoly?.vertices?[0].x)!),
                                        y:CGFloat((item.boundingPoly?.vertices?[0].y)!)) ,
                                                                           scale: self.imageScale!)
                            let point2 = ManagerPoint().getPointsWithScale(points:
                                CGPoint(x:CGFloat((item.boundingPoly?.vertices?[1].x)!),
                                        y:CGFloat((item.boundingPoly?.vertices?[1].y)!)) ,
                                                                           scale: self.imageScale!)
                            let point3 = ManagerPoint().getPointsWithScale(points:
                                CGPoint(x:CGFloat((item.boundingPoly?.vertices?[2].x)!),
                                        y:CGFloat((item.boundingPoly?.vertices?[2].y)!)) ,
                                                                           scale: self.imageScale!)
                            let point4 = ManagerPoint()
                                .getPointsWithScale(points:
                                    CGPoint(x:CGFloat((item.boundingPoly?.vertices?[3].x)!),
                                            y:CGFloat((item.boundingPoly?.vertices?[3].y)!)) ,
                                                    scale: self.imageScale!)
                            
                            ManagerDraw().addLine(fromPoint: point1, toPoint: point2, imageView: self.lineImageView, width: self.lineWIdth, color: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.8))
                            ManagerDraw().addLine(fromPoint: point2, toPoint: point3, imageView: self.lineImageView, width: self.lineWIdth, color: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.8))
                            ManagerDraw().addLine(fromPoint: point3, toPoint: point4, imageView: self.lineImageView, width: self.lineWIdth, color: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.8))
                            ManagerDraw().addLine(fromPoint: point4, toPoint: point1, imageView: self.lineImageView, width: self.lineWIdth, color: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.8))
                            
                            let orcBoxRect: [CGPoint] = [point1, point2, point3, point4]
                            
                            // 직사각형이 아닌 vertex는 touch point포함여부를 검색할수 없기 떄문에 직사각형화 한다.
                            let rectX1 = point1.x < point4.x ? point1.x : point4.x
                            let rectX2 = rectX1 == point1.x ? point3.x : point2.x
                            let rextY1 = point1.y < point2.y ? point1.y : point2.y
                            let rextY2 = rectX1 == point1.y ? point3.y : point4.y
                            
                            let points: [CGPoint] = [point1, point2, point3, point4]
                            
                            let minX = points.reduce(CGPoint(x:CGFloat.greatestFiniteMagnitude,
                                                             y:CGFloat.greatestFiniteMagnitude)) {
                                                                CGPoint(x: min($0.x,$1.x), y: $0.y)
                                }.x
                            
                            let maxX = points.reduce(CGPoint(x:CGFloat.leastNormalMagnitude,
                                                             y:CGFloat.leastNormalMagnitude)) {
                                                                CGPoint(x: max($0.x,$1.x), y: $0.y)
                                }.x
                            
                            let minY = points.reduce(CGPoint(x:CGFloat.greatestFiniteMagnitude,
                                                             y:CGFloat.greatestFiniteMagnitude)) {
                                                                CGPoint(x: $0.x, y: min($0.y,$1.y))
                                }.y
                            
                            let maxY = points.reduce(CGPoint(x:CGFloat.leastNormalMagnitude,
                                                             y:CGFloat.leastNormalMagnitude)) {
                                                                CGPoint(x: $0.x, y: max($0.y,$1.y))
                                }.y
                            
                            
//                            let rectWidth = rectX2 - rectX1
//                            let rectHeight = rextY2 - rextY1
//                            let customBoxRect = CGRect(x: rectX1,
//                                                       y: rextY1,
//                                                       width: rectWidth,
//                                                       height: rectHeight)

                            let rectWidth = maxX - minX
                            let rectHeight = maxY - minY
                            let customBoxRect = CGRect(x: minX, y: minY, width: rectWidth, height: rectHeight)
                            
                            let boxDic = ["org" : orcBoxRect,
                                          "custom" : customBoxRect] as [String : Any]
                            
                            self.boxRectsDic[index] = boxDic as [String : AnyObject]
                        }
                    }
                }
            } else {
                Alert().showAlert(GTranslateConstants.Text().getTextFailTranslateDefault())
            }
        }, errorHandler: { (error) in
            self.hideSnackBarLoadingView()
            
            // 취소코드를 제외한 건만 알럿으로 표시
            if error.code != -999 {
                Alert().showAlert(GTranslateConstants.Text().getTextSendingFailMessage(code: error.code))
            }
        })
    }
    
    fileprivate func requestTranslateAPIFromBox() {
        let gTextRequestModel = GTranslateTextV2RequestModel()
        
        gTextRequestModel.key = apiKey
        gTextRequestModel.source = textRequestModel.source
        gTextRequestModel.target = textRequestModel.target
        gTextRequestModel.format = textRequestModel.format
        gTextRequestModel.q = inputText
        CommonAPI.sharedInstance.httpRequestGTranslateTextV2(params: gTextRequestModel, completionHandler: { (repsonse) in
            let responseModel : GTranslateTextV2ResponseModel = repsonse
            
            log.info(responseModel.data?.translations?.first?.translatedText)
            
            self.outputText = (responseModel.data?.translations?.first?.translatedText)!
            
            self.tableView.reloadData()
            self.refreshTableViewHeight()
            
            let _ = self.requestAddImageRecentData()
        }, errorHandler: { (error) in
            // 취소코드를 제외한 건만 알럿으로 표시
            if error.code != -999 {
                Alert().showAlert(GTranslateConstants.Text().getTextSendingFailMessage(code: error.code))
            }
        })
    }
    
    fileprivate func requestAddImageRecentData() -> Bool {
        if inputText == "" && outputText == "" {
            return false
        }
        
        var requestParams: [String: String] = [:]
        
        requestParams["GUID"] = ManagerTranslate.sharedInstance.getRandomID()
        requestParams["memberNO"] = ""
        requestParams["beforeLanguageCode"] = textRequestModel.source
        requestParams["afterLanguageCode"] = textRequestModel.target
        requestParams["beforeConversion"] = inputText
        requestParams["afterConversion"] = outputText
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
            
            self.delegate?.gTranslateVisionPhotoViewwControllerAddTempRecentData(recentData: gRecentData)
            
        }) { (error) in
            
        }
        
        return true
    }
    
    fileprivate func checkPathFromVertex(_ fromPoint: CGPoint, toPoint: CGPoint) {
        let brushScale = brushWidth / zoomScrollView.zoomScale
        let brushWidthMergeValue = brushScale / 2
        
        let convertFromPoint = CGPoint(x: fromPoint.x / imageScale!, y: fromPoint.y / imageScale!)
        let convertToPoint = CGPoint(x: toPoint.x / imageScale!, y: toPoint.y / imageScale!)
        
        for (key, boxRect) in boxRectsDic {
            let boxString: String? = self.responseModel?.responses?.first?.textAnnotations?[key].description
            if boxString != nil {
                var isContain = false
                
                if convertFromPoint.y == convertToPoint.y {
                    for index in 1...Int(brushWidthMergeValue) {
                        var compareFromPoint = convertFromPoint
                        var compareToPoint = convertToPoint
                        
                        for i in 1...2 {
                            if i == 1 {
                                compareFromPoint.y = convertFromPoint.y - CGFloat(index)
                                compareToPoint.y = convertToPoint.y - CGFloat(index)
                            } else {
                                compareFromPoint.y = convertFromPoint.y + CGFloat(index)
                                compareToPoint.y = convertToPoint.y + CGFloat(index)
                            }
                            
                            if (boxRect["custom"] as! CGRect).instersectsLine(start: compareFromPoint, end: compareToPoint) {
                                
                                fillResultText(index: key, boxString: boxString!)
                                updateLines(points: boxRect["org"]! as! [CGPoint])
                                
                                isContain = true
                                break
                            }
                        }
                        
                        if isContain {
                            break
                        }
                    }
                } else {
                    for index in 1...Int(brushWidthMergeValue) {
                        var compareFromPoint = convertFromPoint
                        var compareToPoint = convertToPoint
                        
                        for i in 1...2 {
                            if i == 1 {
                                compareFromPoint.x = convertFromPoint.x - CGFloat(index)
                                compareToPoint.x = convertToPoint.x - CGFloat(index)
                            } else {
                                compareFromPoint.x = convertFromPoint.x + CGFloat(index)
                                compareToPoint.x = convertToPoint.x + CGFloat(index)
                            }
                            
                            if (boxRect["custom"] as! CGRect).instersectsLine(start: compareFromPoint, end: compareToPoint) {
                                
                                fillResultText(index: key, boxString: boxString!)
                                updateLines(points: boxRect["org"]! as! [CGPoint])
                                
                                isContain = true
                                break
                            }
                        }
                        
                        if isContain {
                            break
                        }
                    }
                }
            }
        }
        
        //        log.info("fromX = \(convertFromPoint.x), fromY = \(convertFromPoint.y)")
        //        log.info("toX = \(convertToPoint.x), toY = \(convertToPoint.y)")
        
        // test by jeanclad
        //        ManagerDraw().addLine(fromPoint: convertFromPoint, toPoint: convertToPoint, imageView: selectedLineImageView, width: 1, color: UIColor.blue)
    }
    
    fileprivate func updateLines(points: [CGPoint]) {
        ManagerDraw().addLine(fromPoint: points[0], toPoint: points[1], imageView: selectedLineImageView, width: lineWIdth, color: ManagerColor().colorFromRGB(lineSelectedColor))
        
        ManagerDraw().addLine(fromPoint: points[1], toPoint: points[2], imageView: selectedLineImageView, width: lineWIdth, color: ManagerColor().colorFromRGB(lineSelectedColor))
        
        ManagerDraw().addLine(fromPoint: points[2], toPoint: points[3], imageView: selectedLineImageView, width: lineWIdth, color: ManagerColor().colorFromRGB(lineSelectedColor))
        
        ManagerDraw().addLine(fromPoint: points[3], toPoint: points[0], imageView: selectedLineImageView, width: lineWIdth, color: ManagerColor().colorFromRGB(lineSelectedColor))
    }
    
    fileprivate func fillResultText(index: Int, boxString: String) {
        // 사용자가 선택한 Box순서에 관계없이 구글 API Response내의 Box 순서로 Sort하여 번역하도록 한다.
        if selectedBoxStringDic?[index] == nil {
            selectedBoxStringDic?[index] = boxString
            
            selectedBoxStringArrTuple = selectedBoxStringDic.flatMap({$0})!.sorted { $0.0.0 < $0.1.0 }
            
            var texts: String = ""
            for tuple in selectedBoxStringArrTuple {
                if texts != "" {
                    texts = texts + " "
                }
                texts = texts.appending(tuple.1)
            }
            
            inputText = texts
        }
    }
    
    fileprivate func refreshTableViewHeight() {
        let currentOffset = tableView.contentOffset
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        tableView.setContentOffset(currentOffset, animated: false)
    }
    
    fileprivate func initGestureAction() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan))
        panGestureRecognizer?.delegate = self
        panGestureRecognizer?.minimumNumberOfTouches = 1
        panGestureRecognizer?.maximumNumberOfTouches = 1
        
        self.view.removeGestureRecognizer(panGestureRecognizer!)
        
        if self.coachView.isHidden == true {
            self.view.addGestureRecognizer(panGestureRecognizer!)
        }
    }
    
    fileprivate func cancelRequestTranslate() {
        CommonAPI.sharedInstance.httpAllRequestCancel()
    }
    
    
    // MARK: Selector
    func handlePan(gestureRecognize: UIPanGestureRecognizer) {
        
        if boxRectsDic.count < 1 {
            return
        }
        
        //        let point = gestureRecognize.location(in: imageView)
        let point = gestureRecognize.location(in: tempImageView)
        
        if gestureRecognize.state == .began {
            log.info("began point = \(point)")
            
            touchFinishTimer?.invalidate()
            touchFinishTimer = nil
            
            if tempImageView.isHidden == false {
                let dummyParam = ""
                clearButtonPressed(dummyParam)
            }
            
            tempImageView.isHidden = true
            drawingBrushImageView.isHidden = false
            
            swiped = false
            lastPoint = point
            
        } else if gestureRecognize.state == .changed {
            log.info("changed point = \(point)")
            
            touchFinishTimer?.invalidate()
            touchFinishTimer = nil
            
            swiped = true
            
            let currentPoint = point
            
            let convertLastPoint = ManagerPoint().getPointsWithScale(points: lastPoint, scale: imageScale!)
            let convertCurrentPoint = ManagerPoint().getPointsWithScale(points: currentPoint, scale: imageScale!)
            
            ManagerDraw().drawLineFrom(lastPoint, toPoint: currentPoint, currentView: zoomScrollView, tempImageView: tempImageView, brushWidth: brushWidth, pencilOpacity: pencelOpacity, mode: .clear)
            ManagerDraw().drawLineFrom(lastPoint, toPoint: currentPoint, currentView: zoomScrollView, tempImageView: drawingBrushImageView, brushWidth: brushWidth, pencilOpacity: pencelOpacity, mode: .copy)
            checkPathFromVertex(convertLastPoint, toPoint: convertCurrentPoint)
            //            ManagerDraw().drawLineFrom(convertLastPoint, toPoint: convertCurrentPoint, currentView: view, tempImageView: tempImageView, brushWidth: brushWidth, pencilOpacity: pencelOpacity)
            //            checkPathFromVertex(lastPoint, toPoint: currentPoint)
            
            // 7
            lastPoint = currentPoint
            
        } else if gestureRecognize.state == .ended {
            log.info("ended point = \(point)")
            
            touchFinishTimer?.invalidate()
            touchFinishTimer = nil
            touchFinishTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTranslate), userInfo: nil, repeats: false)
            
            //            if !swiped {
            //
            //            }
            
            let currentPoint = point
            
            let convertLastPoint = ManagerPoint().getPointsWithScale(points: lastPoint, scale: imageScale!)
            let convertCurrentPoint = ManagerPoint().getPointsWithScale(points: currentPoint, scale: imageScale!)
            
            ManagerDraw().drawLineFrom(lastPoint, toPoint: currentPoint, currentView: zoomScrollView, tempImageView: tempImageView, brushWidth: brushWidth, pencilOpacity: pencelOpacity, mode: .clear)
            ManagerDraw().drawLineFrom(lastPoint, toPoint: currentPoint, currentView: zoomScrollView, tempImageView: drawingBrushImageView, brushWidth: brushWidth, pencilOpacity: pencelOpacity, mode: .copy)
            checkPathFromVertex(convertLastPoint, toPoint: convertCurrentPoint)
            
            tableView.reloadData()
        }
    }
    
    func runTranslate() {
        touchFinishTimer?.invalidate()
        touchFinishTimer = nil
        
        cancelRequestTranslate()
        requestTranslateAPIFromBox()
        
        self.drawingBrushImageView.isHidden = true
        self.tempImageView.isHidden = false
    }
    
    // MARK: Action
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
        self.delegate?.gTranslateVisionPhotoViewContollerRestart()
    }
    
    @IBAction func clearButtonPressed(_ sender: Any) {
        cancelRequestTranslate()
        
        selectedBoxStringDic = [:]
        selectedBoxStringArrTuple = []
        
        inputText = ""
        outputText = ""
        
        tableView.reloadData()
        
        if selectedLineImageView.layer.sublayers != nil && (selectedLineImageView.layer.sublayers?.count)! > 0 {
            for layer in selectedLineImageView.layer.sublayers! {
                layer.removeFromSuperlayer()
            }
        }
        
        tempImageView.image = nil
        drawingBrushImageView.image = nil
        
        let image = UIImage.imageWithColor(color: UIColor.init(red: 0, green: 0, blue: 0, alpha: imageDefultAlpha), rect: tempImageView.frame)
        tempImageView.image = image
        drawingBrushImageView.image = image
    }
    
    @IBAction func coachViewCloseButtonPressed(_ sender: Any) {
        ManagerAnimation().animateOut(self.coachView, duration: 0.3, delay: 0, completionHandler: {
            
            if self.childViewControllers.last?.isKind(of: GTranslateCoachMarkPageViewController.classForCoder()) == true {
                let coachMarkPageViewController = self.childViewControllers.last as! GTranslateCoachMarkPageViewController
                coachMarkPageViewController.showViewController(index: 0)
            }
            self.initGestureAction()
        })
    }
    
    @IBAction func showCoachViewButtonPressed(_ sender: Any) {
        GTranslateConstants.IUserDefault().saveRunCoachGuide(isRunCoachGuide: true)
        ManagerAnimation().animateIn(coachView, duration: 0.3, delay: 0, completionHandler: {
            
        })
        initGestureAction()
    }
    
    // MARK: UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let inputHeight = ManagerView().heightForView(text: inputText, font: UIFont.systemFont(ofSize: 19), width: 315)
        let outputHeight = ManagerView().heightForView(text: outputText, font: UIFont.systemFont(ofSize: 19), width: 315)
        var totalHeight = inputHeight + outputHeight + 16 + 7 + 10 + 10
        
        if totalHeight > 179 {
            totalHeight = 179
        }
        
        if inputHeight == 0 && outputHeight == 0 {
            totalHeight = 0
        }
        
        tableView.frame = CGRect(origin: tableView.frame.origin,
                                 size: CGSize(width: tableView.frame.size.width,
                                              height: totalHeight))
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "VisionInputTableViewCell", for: indexPath) as! VisionInputTableViewCell
            cell.inputTextView.text = inputText
            
            if cell.inputTextView.text.utf16.count > 0 {
                cell.clearTextButton.isHidden = false
            } else {
                cell.clearTextButton.isHidden = true
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "VisionOutputTableViewCell", for: indexPath) as! VisionOutputTableViewCell
            cell.outputTextView.text = outputText
            
            if cell.outputTextView.text.utf16.count > 0 {
                cell.fullTextButton.isHidden = false
            } else {
                cell.fullTextButton.isHidden = true
            }
            
            return cell
        }
    }
    
    
    // MARK: UIGestureRecognizerDelegate
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    // MARK: UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return itemView
        
    }
    
    // MARK: UIStoryboardSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination.isKind(of: GTranslateFullTextViewController.classForCoder()) == true {
            let dest = segue.destination as! GTranslateFullTextViewController
            dest.selectedFunctionType = GTranslateConstants.SelectFunctionType.camera
            dest.delegate = self
            
            let indexPath = IndexPath.init(row: GTranslateConstants.TextViewCellIndex.outputCellIndex.rawValue, section: 0)
            let cell = tableView.cellForRow(at: indexPath) as! VisionOutputTableViewCell
            
            dest.text = cell.outputTextView.text
        }
    }
    
    // MARK: GTranslateFullTextViewDelegate
    func gTranslateFullTextViewControllerAudioStart() {
        self.navigationController?.popViewController(animated: true)
        self.delegate?.gTranslateVisionPhotoViewControllerAudioStart()
    }
}

class VisionInputTableViewCell: UITableViewCell {
    @IBOutlet var inputTextView: UITextView!
    @IBOutlet var clearTextButton: UIButton!
}

class VisionOutputTableViewCell: UITableViewCell {
    @IBOutlet var outputTextView: UITextView!
    @IBOutlet var fullTextButton: UIButton!
}


