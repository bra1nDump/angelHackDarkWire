//
//  LoginViewController.swift
//  AngelHackDarkWire
//
//  Created by KirillDubovitskiy on 6/16/18.
//  Copyright © 2018 Kirill Dubovitskiy. All rights reserved.
//

import UIKit
import Alamofire
import AgoraSigKit

class LoginViewController: UIViewController {
    @IBOutlet weak var userNicknameTextField: UITextField!
    
    let agoraAPI = AgoraAPI.getInstanceWithoutMedia(AgoraConfig.appID.rawValue)!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dialViewController = segue.destination as? DialViewController {
            dialViewController.agoraAPI = agoraAPI
        }
    }
}

// MARK: UI actions
extension LoginViewController {
    @IBAction func loginButtonPressed(_ sender: Any) {
        loginToAgora()
    }
}

extension LoginViewController {
    func loginToAgora() {
        guard let nickname = userNicknameTextField.text,
            nickname != "" else {
                return
        }
        
        agoraAPI.onLogout = { (_) in
            print("logout")
            //self.login(nickname: nickname)
        }
        
        /* Set the onLoginSuccess callback. */
        agoraAPI.onLoginSuccess = { (uid,fd) -> () in
            print("onLoginSuccess")
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "showDial", sender: self)
            }
        }
        
        /* Set the onLoginFailed callback. */
        agoraAPI.onLoginFailed = {(ecode) -> () in
            print("onLoginFailed")
        }
        
        /* Set the onMessageInstantReceive callback. */
        agoraAPI.onMessageInstantReceive = { (account, uid, msg) -> () in
            print("receieved message from account: ", account)
        }
        
        print(nickname)
        login(nickname: nickname)
    }
    
    func login(nickname: String) {
        Alamofire.request("https://dark-wire-backend-nodejs.herokuapp.com/getToken/" + nickname).responseString { response in
            guard response.error == nil else {
                print("something went wrong, failed to obtain token")
                return
            }
            
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            
            if let token = response.result.value {
                print("token: \(token)") // serialized json response
                
                self.agoraAPI.login2(AgoraConfig.appID.rawValue, account: nickname,
                                        token: token, uid: 0, deviceID: nil,
                                        retry_time_in_s: 60, retry_count: 5)
            }
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)") // original server data as UTF8 string
            }
        }
    }
}

