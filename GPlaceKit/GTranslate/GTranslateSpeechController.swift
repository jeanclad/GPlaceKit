//
//  GTranslateSpeechController.swift
//  main
//
//  Created by jeanclad on 2017. 4. 27..
//  Copyright © 2017년 interpark-int. All rights reserved.
//

import Foundation
import Speech

protocol GTranslateSpeechControllerDelegate {
    func GTranslateSpeechControllerAudioVolume(volume: Float)
    func GTranslateSpeechControllerDelegateAuth(isEnabled: Bool)
    func GTranslateSpeechControllerDelegateResultText(message: String, isFinal: Bool)
    func GTranslateSpeechControllerFinished()
}

@available(iOS 10.0, *)
class GTranslateSpeechController: NSObject, SFSpeechRecognizerDelegate {
    
    static var sharedInstance = GTranslateSpeechController()
    var delegate: GTranslateSpeechControllerDelegate?
    
    // Speech
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var speechFinishtimer: Timer?
    
    func prepare() {
        log.info("supported locales = \(SFSpeechRecognizer.supportedLocales())")
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            // FIXME: button
            var isSpeechEnabled = false
            
            switch authStatus {
            case .authorized:
                isSpeechEnabled = true
                
            case .denied:
                isSpeechEnabled = false
                log.info("User denied access to speech recognition")
                
            case .restricted:
                isSpeechEnabled = false
                log.info("Speech recognition restricted on this device")
                
            case .notDetermined:
                isSpeechEnabled = false
                log.info("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.delegate?.GTranslateSpeechControllerDelegateAuth(isEnabled: isSpeechEnabled)
            }
        }
    }
    
    func startRecording(locale: Locale) {
        guard let speechRecognizer = SFSpeechRecognizer(locale: locale) else {
            log.info("set input lang = \(locale)")
            Alert().showAlert(GTranslateConstants.Text().getTextNotSupportedLanguage())
            return
        }
        
        speechRecognizer.delegate = self
        
        if recognitionTask != nil {  //1
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()  //2
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()  //3
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }  //4
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        } //5
        
        recognitionRequest.shouldReportPartialResults = true  //6
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in  //7
            
            var isFinal = false  //8
            
            if result != nil {
                
                let message = result?.bestTranscription.formattedString
                
                log.info("speech text: \(String(describing: result?.bestTranscription.formattedString))")
                
                isFinal = (result?.isFinal)!
                log.info("isFianl = \(isFinal)")
                
                if self.audioEngine.isRunning {
                    self.delegate?.GTranslateSpeechControllerDelegateResultText(message: message!, isFinal: isFinal)
                }
            }
            
            if error != nil || isFinal {  //10
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
//                self.delegate?.GTranslateSpeechControllerFinished()
            }
            
            self.speechFinishtimer?.invalidate()
            self.speechFinishtimer = nil
            
            self.speechFinishtimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { (timer) in
                log.info("no more input!")
                
                self.speechFinishtimer?.invalidate()
                self.speechFinishtimer = nil
                
                if isFinal == false {
                    self.delegate?.GTranslateSpeechControllerFinished()
                }
            })
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)  //11
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)

            let dataptrptr = buffer.floatChannelData!           //Get buffer of floats
            let dataptr = dataptrptr.pointee
            let datum = dataptr[Int(buffer.frameLength) - 1]    //Get a single float to read
            
            //store the float on the variable
            let volumeFloat = fabs((datum))
            
//            log.info("volume = \(volumeFloat)")
        
            self.delegate?.GTranslateSpeechControllerAudioVolume(volume: volumeFloat)
        }
        
        audioEngine.prepare()  //12
        
        do {
            try audioEngine.start()
        } catch {
            log.info("audioEngine couldn't start because of an error.")
        }
    }
    
    func stopRecording() {
        self.speechFinishtimer?.invalidate()
        self.speechFinishtimer = nil
        
        audioEngine.stop()
        recognitionRequest?.endAudio()
    }
    
    func isRunning() -> Bool {
        if audioEngine.isRunning == true {
            return true
        }
        
        return false
    }
    
    // MARK: SFSpeechRecognizerDelegate
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer,
                          availabilityDidChange available: Bool) {
        delegate?.GTranslateSpeechControllerDelegateAuth(isEnabled: available)
    }
}
