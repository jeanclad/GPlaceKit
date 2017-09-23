//
//  GTranslateFullTextViewController.swift
//  main
//
//  Created by jeanclad on 2017. 5. 26..
//  Copyright © 2017년 interpark-int. All rights reserved.
//

import Foundation

protocol GTranslateFullTextViewControllerDelegate {
    func gTranslateFullTextViewControllerAudioStart()
}

class GTranslateFullTextViewController: UIViewController {
    @IBOutlet var textView: UITextView!
    @IBOutlet var replyButton: UIButton!
    @IBOutlet var replyButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet var muteButton: UIButton!
    
    var text: String?
    var selectedFunctionType = GTranslateConstants.SelectFunctionType.text
    var delegate: GTranslateFullTextViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if selectedFunctionType == GTranslateConstants.SelectFunctionType.audio {
            view.backgroundColor = ManagerColor().colorFromRGB(GTranslateConstants.ColorBG.audio.rawValue)
        } else if selectedFunctionType == GTranslateConstants.SelectFunctionType.camera {
            view.backgroundColor = ManagerColor().colorFromRGB(GTranslateConstants.ColorBG.camera.rawValue)
        }
        
        textView.textContainerInset = UIEdgeInsetsMake(54, 60, 110, 60)
        textView.scrollsToTop = true
        
        textView.isZoomEnabled = true
        textView.minFontSize = 20
        textView.maxFontSize = 90
        
        textView.text = text!
        
        textView.contentOffset = CGPoint(x: 0, y: -60)
        
        var replyButtonTitle = ManagerTranslate.sharedInstance.getDstLangModel()?.answerText
        
        if replyButtonTitle == nil {
            replyButtonTitle = GTranslateConstants.Text().getTextDefaultReply()
        }
        
        let replyTextFrame = ManagerView().labelSizeWithString(text: replyButtonTitle!, fontSize: 17, isBold: false, maxWidth: 500, numberOfLines: 1)
        
        if #available(iOS 10.0, *) {
            replyButton.setTitle(replyButtonTitle, for: .normal)
            replyButtonWidthConstraint.constant = replyTextFrame.width + 26.5 + 15.5 + 13 + 26.5 + 10
        } else {
            replyButton.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        ManagerTTS.sharedInstance.ttsStop()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let speechLangCode = ManagerTranslate.sharedInstance.getDstLangModel()?.ttsCodeIOS
        let notAutoTTS = GTranslateConstants.IUserDefault().loadNotAutoTTS()
        
        if notAutoTTS == false {
            muteButton.isSelected = false
            ManagerTTS.sharedInstance.ttsStart(lang: speechLangCode!, text: textView.text)
        } else {
            muteButton.isSelected = true
        }
        
    }
    
    
    // MARK: Action
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func audioButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: {
            self.delegate?.gTranslateFullTextViewControllerAudioStart()
        })
    }
    
    @IBAction func muteButtonPressed(_ sender: Any) {
        let button = sender as! UIButton
        
        if button.isSelected == true {
            button.isSelected = false
            let speechLangCode = ManagerTranslate.sharedInstance.getDstLangModel()?.ttsCodeIOS
            ManagerTTS.sharedInstance.ttsStart(lang: speechLangCode!, text: textView.text)
            GTranslateConstants.IUserDefault().saveNotAutoTTS(isNotAuto: false)
        } else {
            button.isSelected = true
            ManagerTTS.sharedInstance.ttsStop()
            GTranslateConstants.IUserDefault().saveNotAutoTTS(isNotAuto: true)
        }
    }
}
