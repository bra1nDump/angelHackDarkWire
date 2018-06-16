//
//  CallViewController.swift
//  AngelHackDarkWire
//
//  Created by KirillDubovitskiy on 6/16/18.
//  Copyright © 2018 Kirill Dubovitskiy. All rights reserved.
//

import UIKit
import AgoraSigKit
import Speech

class CallViewController: UIViewController {
    var agoraAPI: AgoraAPI!
    var calleeAccount: String!
    
    let audioEngine = AVAudioEngine.init()
    let synthesizer = AVSpeechSynthesizer.init()
    
    let recognitionRequest = SFSpeechAudioBufferRecognitionRequest.init()
    let speechRecognizer = SFSpeechRecognizer.init()

    override func viewDidLoad() {
        super.viewDidLoad()

        synthesizer.delegate = self
        joinCall()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CallViewController {
    func joinCall() {
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
        
        agoraAPI.onMessageInstantReceive = { (account, uid, message) in
            guard let message = message else {
                return
            }
            
            print("recieved message: ", message, " from account: ", account)
            
            DispatchQueue.main.async {
                let utterance = AVSpeechUtterance.init(string: message)
                self.synthesizer.speak(utterance)
            }
        }
        
        /* Set the onMessageSendSuccess callback. */
        agoraAPI.onMessageSendSuccess = { (messageID) -> () in
            print("message send successfully: ", messageID!)
        }
        
        /* Set the onMessageSendError callback. */
        agoraAPI.onMessageSendError = { (messageID, ecode) -> () in
            print("message send failed: ", messageID!)
        }
    }
}

extension CallViewController: SFSpeechRecognitionTaskDelegate {
    // Called when the task first detects speech in the source audio
    func speechRecognitionDidDetectSpeech(_ task: SFSpeechRecognitionTask) {
        print("speechRecognitionDidDetectSpeech")
    }
    
    
    // Called for all recognitions, including non-final hypothesis
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didHypothesizeTranscription transcription: SFTranscription) {
        print("didHypothesizeTranscription")
        if let newWord = transcription.segments.last {
            print("newWord: ", newWord.substring)
            print("sending to account: ", calleeAccount)
            agoraAPI.messageInstantSend(calleeAccount, uid: 0, msg: newWord.substring, msgID: nil)
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
        
        speechRecognizer?.recognitionTask(with: recognitionRequest, delegate: self)
    }
}

extension CallViewController: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("synthesizer didStart")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("synthesizer didFinish")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        print("synthesizer didPause")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        print("synthesizer didContinue")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print("synthesizer didCancel")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        print("synthesizer willSpeakRangeOfSpeechString")
    }
}



