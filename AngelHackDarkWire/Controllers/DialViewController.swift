//
//  ViewController.swift
//  AngelHackDarkWire
//
//  Created by KirillDubovitskiy on 6/15/18.
//  Copyright © 2018 Kirill Dubovitskiy. All rights reserved.
//

import UIKit
import Speech
import AgoraSigKit

class DialViewController: UIViewController {
    @IBOutlet weak var calleeUserNameTextField: UITextField!
    @IBOutlet weak var callButton: UIButton!

    var agoraAPI: AgoraAPI!
    var partnerAccount: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestRecognitionAuthorization()
        listenOnIncommingMessages()
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
}

extension DialViewController {
    func listenOnIncommingMessages() {
        agoraAPI.onMessageInstantReceive = { (account, uid, message) in
            self.partnerAccount = account
            self.agoraAPI.onMessageInstantReceive = nil
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "showCall", sender: self)
            }
        }
    }
}


extension DialViewController {
    @IBAction func callButtonPressed(_ sender: Any) {
        partnerAccount = calleeUserNameTextField.text
        performSegue(withIdentifier: "showCall", sender: self)
    }
}

extension DialViewController: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer,
                          availabilityDidChange available: Bool) {
        print("availabilityDidChange", available)
    }
}

extension DialViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let callViewController = segue.destination as? CallViewController {
            callViewController.agoraAPI = agoraAPI
            callViewController.calleeAccount = self.partnerAccount
        }
    }
}

