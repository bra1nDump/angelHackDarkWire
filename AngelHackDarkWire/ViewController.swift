//
//  ViewController.swift
//  AngelHackDarkWire
//
//  Created by KirillDubovitskiy on 6/15/18.
//  Copyright © 2018 Kirill Dubovitskiy. All rights reserved.
//

import UIKit
import Speech
import AVFoundation
import AgoraSigKit

class ViewController: UIViewController {
    @IBOutlet weak var userNicknameTextField: UITextField!
    @IBOutlet weak var calleeUserNameTextField: UITextField!
    
    @IBOutlet weak var callButton: UIButton!

    
    let audioEngine = AVAudioEngine.init()

    let recognitionRequest = SFSpeechAudioBufferRecognitionRequest.init()
    let speechRecognizer = SFSpeechRecognizer.init()
    
    // --------- agora -------------
    /* Initialize the SDK. */
    let agoraSignalKit = AgoraAPI.getInstanceWithoutMedia(AgoraConfig.appID.rawValue)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestRecognitionAuthorization()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func requestRecognitionAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            /* The callback may not be called on the main thread. Add an
             operation to the main queue to update the record button's state.
             */
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.callButton.isEnabled = true
                case .denied:
                    self.callButton.isEnabled = false
                    self.callButton.setTitle("User denied access to speech recognition", for: .disabled)
                case .restricted:
                    self.callButton.isEnabled = false
                    self.callButton.setTitle("Speech recognition restricted on this device", for: .disabled)
                case .notDetermined:
                    self.callButton.isEnabled = false
                    self.callButton.setTitle("Speech recognition not yet authorized", for: .disabled)
                }
            }
        }
    }
    
    func loginToAgora() {
        /* Set the onLoginSuccess callback. */
        agoraSignalKit.onLoginSuccess = { (uid,fd) -> () in
            /* Your code. */
        }
        
        /* Set the onLoginFailed callback. */
        agoraSignalKit.onLoginFailed = {(ecode) -> () in
            /* Your code. */
        }
        
        /* Set the onMessageInstantReceive callback. */
        agoraSignalKit.onMessageInstantReceive = { (account, uid, msg) -> () in
            /* Your code. */
        }
        
    }

    func startRecognition() {
        speechRecognizer?.delegate = self
        recognitionRequest.shouldReportPartialResults = true
        
        let recordingBus: AVAudioNodeBus = 0
        let recordingNode = audioEngine.inputNode
        let recordingFormat = recordingNode.outputFormat(forBus: recordingBus)
        recordingNode.installTap(onBus: recordingBus, bufferSize: 1024, format: recordingFormat) {
            (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest.append(buffer)
        }
        
        // Prepare and start the audio engine (not shown).
        do {
            try audioEngine.start()
        } catch {
            print("some error occured")
        }
        
        speechRecognizer?.recognitionTask(with: recognitionRequest, delegate: self)
    }
}

extension ViewController: SFSpeechRecognitionTaskDelegate {
    // Called when the task first detects speech in the source audio
    func speechRecognitionDidDetectSpeech(_ task: SFSpeechRecognitionTask) {
        print("speechRecognitionDidDetectSpeech")
    }
    
    
    // Called for all recognitions, including non-final hypothesis
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didHypothesizeTranscription transcription: SFTranscription) {
        print("didHypothesizeTranscription")
        if let newSegment = transcription.segments.last {
            print(newSegment)
        }
    }
    
    
    // Called only for final recognitions of utterances. No more about the utterance will be reported
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishRecognition recognitionResult: SFSpeechRecognitionResult) {
        print("didFinishRecognition")
    }
    
    
    // Called when the task is no longer accepting new audio but may be finishing final processing
    func speechRecognitionTaskFinishedReadingAudio(_ task: SFSpeechRecognitionTask) {
        print("speechRecognitionTaskFinishedReadingAudio")
    }
    
    
    // Called when the task has been cancelled, either by client app, the user, or the system
    func speechRecognitionTaskWasCancelled(_ task: SFSpeechRecognitionTask) {
        print("speechRecognitionTaskWasCancelled")
    }
    
    
    // Called when recognition of all requested utterances is finished.
    // If successfully is false, the error property of the task will contain error information
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishSuccessfully successfully: Bool) {
        print("task didFinishSuccessfully")
    }
}

extension ViewController {
    @IBAction func callButtonPressed(_ sender: Any) {
        startRecognition()
    }
}

extension ViewController: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer,
                          availabilityDidChange available: Bool) {
        print("availabilityDidChange", available)
    }
}

